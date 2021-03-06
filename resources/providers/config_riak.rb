 # Cookbook Name:: riak
# Provider:: config_riak
#

action :config do
  begin
    config_dir = new_resource.config_dir
    logdir = new_resource.logdir
    user = new_resource.user
    group = new_resource.group
    riak_ip = new_resource.riak_ip
    riak_port = new_resource.riak_port
    riak_port_http = new_resource.riak_port_http

    template "#{config_dir}/riak.conf" do
      source "riak.conf.erb"
      owner user
      group group
      mode 0644
      retries 2
      cookbook "riak"
      variables(:riak_ip => riak_ip, :riak_port => riak_port, :riak_port_http => riak_port_http, :logdir => logdir)
    end

    template "#{config_dir}/advanced.config" do
       source "advanced.config.erb"
       owner user
       group group
       mode 0644
       retries 2
       cookbook "riak"
       variables(:riakcs_version => node["riak-cs"]["version"])
    end

    service "riak" do
      service_name "riak"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action [:enable,:start]
    end

    Chef::Log.info("Riak has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    service "riak" do
      supports :stop => true, :disable => true
      action [:stop, :disable]
    end

    Chef::Log.info("Riak is disabled")
  rescue => e
    Chef::Log.error(e.message)
  end
end
