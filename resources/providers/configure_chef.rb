# Cookbook Name:: riak
# Provider:: configure_chef
#

action :configure do
  begin
    erchef_conf = new_resource.erchef_conf
    cdomain = new_resource.cdomain

    s3_secrets = Chef::DataBagItem.load("passwords", "s3_secrets") rescue s3_secrets = {}

    # Check if rbookshelf bucket has been created
    rbookshelf-bucket = Chef::DataBagItem.load("rBglobal", "rbookshelf-bucket") rescue bucket_created_dg =  {}
    bucket_created = rbookshelf-bucket["created"]
    bucket_created = false  if bucket_created!=true

    bash 'change_chef_conf' do
      ignore_failure true
      only_if { bucket_created and !node["redborder"]["uploaded_s3"]}
      code <<-EOH
        sed -i 's|s3_access_key_id,.*|s3_access_key_id, \"#{s3_secrets["key_id"]}\"},|' #{erchef_conf}
        sed -i 's|s3_secret_key_id,.*|s3_secret_key_id, \"#{s3_secrets["key_id"]}\"},|' #{erchef_conf}
        sed -i 's|s3_url,.*|s3_url, \"rbookshelf.s3.#{cdomain}\"},|' #{erchef_conf}
        sed -i 's|s3_external_url,.*|s3_external_url, \"#{cdomain}\"},|' #{erchef_conf}
        sed -i 's|s3_platform_bucket_name,.*|s3_platform_bucket_name, \"rbookshelf\"},|' #{erchef_conf}
        EOH
      action :run
      notifies :run, "execute[erchef_restart]", :immediately
    end

    riak_configure_chef "riak_upload_cookbooks" do
      only_if { bucket_created and !node["redborder"]["uploaded_s3"]}
      action :upload_cookbooks
    end

    execute "erchef_restart" do
      command "systemctl restart opscode-erchef"
      ignore_failure true
      action :nothing
    end

    Chef::Log.info("Cookbooks uploaded to Riak successfully.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :upload_cookbooks do
  begin
    # Check if rbookshelf bucket has been created
    bucket_created_dg = Chef::DataBagItem.load("rBglobal", "rbookshelf-bucket") rescue bucket_created_dg =  {}
    bucket_created = bucket_created_dg["created"]
    bucket_created = false  if bucket_created!=true

    execute "delete_bookshelf_cookbooks" do
      command "for i in `ls /var/chef/cookbooks`;do knife cookbook delete $i -y;done"
      ignore_failure true
      only_if { bucket_created and !node["redborder"]["uploaded_s3"]}
      action :run
    end

    execute "upload_riak_cookbooks" do
      command "for i in zookeeper kafka druid nomad http2k cron memcached chef-server riak rb-manager;do knife cookbook upload $i;done" #User rb-manager attribute
      ignore_failure true
      only_if { bucket_created and !node["redborder"]["uploaded_s3"]}
      action :run
      notifies :create, "ruby_block[uploaded_s3]", :immediately
    end

    ruby_block "uploaded_s3" do
      block do
       node.set["redborder"]["uploaded_s3"] = true
      end
      action :nothing
    end

    Chef::Log.info("Cookbooks uploaded to Riak successfully.")
  rescue => e
    Chef::Log.error(e.message)
  end
end
