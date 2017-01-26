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

action :config_solo do
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

    # Get some init configurations
    init_conf = YAML.load_file("/etc/redborder/rb_init_conf.yml")
    cdomain = init_conf['cdomain']

    # Get S3 keys
    s3_init_conf = YAML.load_file("/etc/redborder/s3_init_conf.yml")
    s3_conf = s3_init_conf['s3']

    s3_access = s3_conf['access_key']
    s3_secret = s3_conf['secret_key']

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

    cdomain = new_resource.cdomain

    # Load keys from s3_secrets data bag
    s3_secrets = Chef::DataBagItem.load("passwords", "s3") rescue s3_secrets = {}

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
        :cdomain => cdomain, :key_id => s3_secrets["s3_access_key_id"], :key_secret => s3_secrets["s3_secret_key_id"])
    end

    service "riak-cs" do
      service_name "riak-cs"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action [:enable,:start]
    end

    Chef::Log.info("Riak-cs has been configurated correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    logdir = new_resource.logdir
    config_dir = new_resource.config_dir

    service "riak-cs" do
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

    yum_package 'riak-cs' do
      action :remove
    end

    Chef::Log.info("riak-cs has been uninstalled correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :create_user do
  begin
    s3cfg_file = new_resource.s3cfg_file

    # Load keys from s3_secrets data bag
    s3_secrets = Chef::DataBagItem.load("passwords", "s3_secrets") rescue s3_secrets = {}

    #if ((!File.exists?("/etc/redborder/s3user.txt") or !s3_secrets["key_created"] ) and File.exists?("/var/run/stanchion/stanchion.pid") and File.exists?("/var/run/riak-cs/riak-cs.pid"))
    execute "create_s3_user" do
      command "ruby /usr/lib/redborder/bin/rb_s3_user.rb -a" #Create admin user
      ignore_failure true
      not_if { ::File.exists?("/etc/redborder/s3user.txt") or !s3_secrets["key_created"]}
      action :run
      #notifies :run, "execute[force_chef_client_wakeup]", :delayed
    end

    template "#{s3cfg_file}" do
        source "s3cfg.erb"
        owner "root"
        group "root"
        mode 0600
        retries 2
        variables(:key_hostname => s3_secrets["hostname"], :key_location => s3_secrets["location"], :key_id => s3_secrets['key_id'], :key_secret => s3_secrets['key_secret'])
    end

  rescue => e
    Chef::Log.error(e.message)
  end
end

action :create_user_solo do
  begin
    s3cfg_file = new_resource.s3cfg_file

    # Get S3 keys
    s3_init_conf = YAML.load_file("/etc/redborder/s3_init_conf.yml")
    s3_conf = s3_init_conf['s3']

    s3_access = s3_conf['access_key']
    s3_secret = s3_conf['secret_key']
    s3_endpoint = s3_conf['endpoint']
    s3_location = s3_conf['location'].nil? ? "US" : s3_conf['location']

    execute "create_s3_user" do
      command "ruby /usr/lib/redborder/bin/rb_s3_user.rb -a" #Create admin user
      ignore_failure true
      not_if { ::File.exists?("/etc/redborder/s3user.txt") or !s3_secrets["key_created"]}
      action :run
    end

    template "#{s3cfg_file}" do
        source "s3cfg.erb"
        owner "root"
        group "root"
        mode 0600
        retries 2
        variables(:s3_endpoint => s3_endpoint, :s3_location => s3_location, :s3_access => s3_access, :s3_secret => s3_secret)
    end

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
        variables(:hostname => node["hostname"], :riakcs_ip => riakcs_ip, :riakcs_port => riakcs_port, :cdomain => cdomain)
        #notifies :restart, "service[nginx]", :delayed # TODO when nginx service is created
        notifies :run, "execute[nginx_restart]", :delayed
    end

    execute "nginx_restart" do
      command "systemctl restart nginx"
      ignore_failure true
      action :nothing
    end

  rescue => e
    Chef::Log.error(e.message)
  end
end

action :set_proxy_solo do
  begin
    proxy_conf = new_resource.proxy_conf
    riakcs_ip = new_resource.riakcs_ip
    riakcs_port = new_resource.riakcs_port
    # Get some init configurations
    init_conf = YAML.load_file("/etc/redborder/rb_init_conf.yml")
    hostname = init_conf['hostname']
    cdomain = init_conf['cdomain']

    template "#{proxy_conf}" do
        source "riak-proxy.conf.erb"
        owner "root"
        group "root"
        mode 0644
        retries 2
        variables(:hostname => hostname, :riakcs_ip => riakcs_ip, :riakcs_port => riakcs_port, :cdomain => cdomain)
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
      command "/usr/lib/redborder/bin/rb_create_buckets"
      ignore_failure true
      action :run
    end

    Chef::Log.info("riak-cs - buckets created.")
  rescue => e
    Chef::Log.error(e.message)
  end
end
