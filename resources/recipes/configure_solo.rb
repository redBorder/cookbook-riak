#
# Cookbook Name:: riak
# Recipe:: configure_solo
#
# 2017, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

# Get some init configurations
init_conf = YAML.load_file("/etc/redborder/rb_init_conf.yml")
cdomain = init_conf['cdomain']

# Get stored S3 information
begin
  s3_user = Chef::JSONCompat.parse(::File.read('/etc/redborder/s3user.json'))
rescue
  s3_user = {"key_id" => "admin-key", "key_secret" => "admin-secret"}
end

nginx_config "config" do
  service_name "s3"
  action [:add, :configure_certs]
end

riak_config_commmon "Riak config common" do
  action :install
end

riak_config_riak "Riak config" do
  config_dir node["riak"]["config_dir"]
  logdir node["riak"]["logdir"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  riak_port_http node["riak"]["port_http"]
  action :config
end

# First time is called s3_access & s3_secret has default values
riak_config_riakcs "Riak-cs config" do
  config_dir node["riak-cs"]["config_dir"]
  logdir node["riak-cs"]["logdir"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  stanchion_ip node["stanchion"]["ip"]
  stanchion_port node["stanchion"]["port"]
  s3_access s3_user['key_id']
  s3_secret s3_user['key_secret']
  cdomain cdomain
  action :config
end

# First time is called s3_access & s3_secret has default values
riak_config_stanchion "stanchion config" do
  config_dir node["stanchion"]["config_dir"]
  logdir node["stanchion"]["logdir"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  stanchion_ip node["stanchion"]["ip"]
  stanchion_port node["stanchion"]["port"]
  s3_access s3_user['key_id']
  s3_secret s3_user['key_secret']
  action :config
end

riak_config_riakcs "Riak-cs create user" do
  action :create_user
end
