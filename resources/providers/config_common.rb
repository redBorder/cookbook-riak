# Cookbook Name:: riak
# Provider:: config_common
#
action :install do
  begin
    user = new_resource.user
    group = new_resource.group

    dnf_package "redborder-riak" do
      action :upgrade
      flush_cache [ :before ]
    end

    group group do
      action :create
    end

    user user do
      group group
      action :create
    end

  rescue => e
    Chef::Log.error(e.message)
  end
end

action :add do
  begin

    cdomain = new_resource.cdomain

    nginx_config "config" do
      service_name "s3"
      action [:add, :configure_certs]
    end

    riak_config_riak "Riak config" do
      config_dir node["riak"]["config_dir"]
      logdir node["riak"]["logdir"]
      riak_ip node["riak"]["ip"]
      riak_port node["riak"]["port"]
      riak_port_http node["riak"]["port_http"]
      action :config
    end

    s3_keys = data_bag_item("passwords","s3") rescue s3_keys = {}

    if !s3_keys.empty?
      riak_config_riakcs "Riak-cs config" do
        config_dir node["riak-cs"]["config_dir"]
        logdir node["riak-cs"]["logdir"]
        riak_ip node["riak"]["ip"]
        riak_port node["riak"]["port"]
        riakcs_ip node["riak-cs"]["ip"]
        riakcs_port node["riak-cs"]["port"]
        stanchion_ip node["stanchion"]["ip"]
        stanchion_port node["stanchion"]["port"]
        s3_access s3_keys['s3_access_key_id']
        s3_secret s3_keys['s3_secret_key_id']
        cdomain cdomain
        action :config
      end
    end

    riak_config_riakcs "Riak-cs configure s3cmd" do
      s3cfg_file node["riak-cs"]["s3cfg_file"]
      cdomain cdomain
      action :configure_s3cmd
    end

    riak_config_riakcs "Riak-cs set proxy" do
      proxy_conf node["riak-cs"]["proxy_conf"]
      riakcs_ip node["riak-cs"]["ip"]
      riakcs_port node["riak-cs"]["port"]
      cdomain cdomain
      action :set_proxy
    end

  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    riak_config_riak "Stop riak" do
      action :remove
    end

    riak_config_riakcs "Stop riak-cs" do
      action :remove
    end

    riak_config_stanchion "Stop stanchion" do
      action :remove
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    consul_servers = system('serf members -tag consul=ready | grep consul=ready &> /dev/null')
    if !node["s3"]["registered"] and consul_servers
      query = {}
      query["ID"] = "s3-#{node["hostname"]}"
      query["Name"] = "s3"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 443
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         retries 3
         retry_delay 2
         action :nothing
      end.run_action(:run)

      node.set["s3"]["registered"] = true
      Chef::Log.info("s3 service has been registered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    consul_servers = system('serf members -tag consul=ready | grep consul=ready &> /dev/null')
    if node["s3"]["registered"] and consul_servers
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/s3-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["s3"]["registered"] = false
      Chef::Log.info("s3 service has been deregistered from consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
