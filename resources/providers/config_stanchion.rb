# Cookbook Name:: riak
# Provider:: config_stanchion
#

action :install do
  begin
    yum_package "stanchion" do
      action :upgrade
      flush_cache [ :before ]
    end

    Chef::Log.info("Stanchion has been installed correctly.")
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

    user user do
      group group
      action :create
    end

    template "#{config_dir}/stanchion.conf" do
      source "stanchion.conf.erb"
      owner user
      group group
      mode 0644
      retries 2
      notifies :restart, "service[stanchion]", :delayed
      variables(:stanchion_ip => stanchion_ip, :stanchion_port => stanchion_port, \
        :riakcs_ip => riakcs_ip, :riakcs_port => riakcs_port, :riak_ip => riak_ip, :riak_port => riak_port, \
        :s3_access => s3_access, :s3_secret => s3_secret, :logdir => logdir)
    end

    service "stanchion" do
      service_name "stanchion"
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
    config_dir = new_resource.config_dir
    logdir = new_resource.logdir

    service "stanchion" do
      supports :stop => true, :disable => true
      action [:stop, :disable]
    end

    Chef::Log.info("stanchion is disabled")
  rescue => e
    Chef::Log.error(e.message)
  end
end
