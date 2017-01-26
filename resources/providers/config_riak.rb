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

    yum_package "riak" do
      action :upgrade
      flush_cache [ :before ]
    end

    group group do
      action  :create
    end

    user user do
      group group
      action :create
    end

    template "#{config_dir}/riak.conf" do
      source "riak.conf.erb"
      owner user
      group group
      mode 0644
      retries 2
      variables(:riak_ip => riak_ip, :riak_port => riak_port, :riak_port_http => riak_port_http, :logdir => logdir)
    end

    template "#{config_dir}/advanced.config" do
       source "advanced.config.erb"
       owner user
       group group
       mode 0644
       retries 2
       variables(:riakcs_version => node["riak-cs"]["version"])
    end

    # riak-cs must have installed before start riak. Then we call to riak-cs resource
    riak_config_riakcs "riak-cs install" do
      action :install
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
    config_dir = new_resource.config_dir
    logdir = new_resource.logdir

    service "riak" do
      supports :stop => true
      action :stop
    end

    dir_list = [
                 config_dir,
                 logdir
               ]

    # removing directories
    dir_list.each do |dirs|
      directory dirs do
        action :delete
        recursive true
      end
    end

    yum_package 'riak' do
      action :remove
    end

    Chef::Log.info("Riak has been uninstalled correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end
