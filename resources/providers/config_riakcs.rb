# Cookbook Name:: riak
# Provider:: config_riakcs
#

action :install do
  begin
    yum_package "riak-cs" do
      action :upgrade
      flush_cache [ :before ]
    end

    Chef::Log.info("Riak-cs has been installed correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :config do
  begin

    config_dir = new_resource.config_dir
    logdir = new_resource.logdir
    user = new_resource.user
    group = new_resource.group

    riak_ip = new_resource.riak_ip
    riak_port = new_resource.riak_port

    riakcs_ip = new_resource.riakcs_ip
    riakcs_port = new_resource.riakcs_port

    stanchion_ip = new_resource.stanchion_ip
    stanchion_port = new_resource.stanchion_port

    s3_access = new_resource.s3_access
    s3_secret = new_resource.s3_secret

    cdomain = new_resource.cdomain

    user user do
      group group
      action :create
    end

    template "#{config_dir}/riak-cs.conf" do
      source "riak-cs.conf.erb"
      owner user
      group group
      mode 0644
      retries 2
      notifies :restart, "service[riak-cs]", :delayed
      variables(:riakcs_ip => riakcs_ip, :riakcs_port => riakcs_port, :riak_ip => riak_ip, \
        :riak_port => riak_port, :stanchion_ip => stanchion_ip, :stanchion_port => stanchion_port, \
        :cdomain => cdomain, :s3_access => s3_access, :s3_secret => s3_secret)
    end

    service "riak-cs" do
      service_name "riak-cs"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action [:enable,:start]
    end

    Chef::Log.info("Riak-cs cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    service "riak-cs" do
      supports :stop => true, :disable => true
      action [:stop, :disable]
    end

    Chef::Log.info("riak-cs is disabled")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :create_user do
  begin
    s3cfg_file = new_resource.s3cfg_file
    cdomain = new_resource.cdomain

    execute "create_s3_user" do
      command "rb_s3_user" #Create admin user
      ignore_failure true
      not_if { ::File.exist?("/etc/redborder/s3user.json") }
      action :run
    end

    Chef::Log.info("riak-cs user created")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :configure_s3cmd do
    #Get access_key and secret_key
    s3_user = Chef::JSONCompat.parse(::File.read('/etc/redborder/s3user.json'))
    s3_access = s3_user['key_id']
    s3_secret = s3_user['key_secret']

    template "#{s3cfg_file}" do
        source "s3cfg.erb"
        owner "root"
        group "root"
        mode 0600
        retries 2
        variables(:cdomain => cdomain, :s3_access => s3_access, :s3_secret => s3_secret)
    end

    Chef::Log.info("s3cmd configured")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :set_proxy do
  begin
    proxy_conf = new_resource.proxy_conf
    riakcs_ip = new_resource.riakcs_ip
    riakcs_port = new_resource.riakcs_port
    cdomain = new_resource.cdomain

    template "#{proxy_conf}" do
        source "riak-proxy.conf.erb"
        owner "root"
        group "root"
        mode 0644
        retries 2
        variables(:riakcs_ip => riakcs_ip, :riakcs_port => riakcs_port, :cdomain => cdomain)
        notifies :restart, "service[nginx]"
    end

    service "nginx" do
      service_name "nginx"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action :nothing
    end

  rescue => e
    Chef::Log.error(e.message)
  end
end

action :create_buckets do
  begin
    execute "create_buckets" do
      command "rb_create_buckets"
      ignore_failure true
      action :run
    end

    Chef::Log.info("riak-cs - buckets created.")
  rescue => e
    Chef::Log.error(e.message)
  end
end
