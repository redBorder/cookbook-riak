#
# Cookbook Name:: riak
# Recipe:: configure_solo
#
# 2017, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

# Get S3 information
s3_init_conf = YAML.load_file("/etc/redborder/s3_init_conf.yml")
s3_access = s3_init_conf['access_key']
s3_secret = s3_init_conf['secret_key']
s3_endpoint = s3_init_conf['endpoint']
s3_location = s3_init_conf['location']

nginx_config "config" do
  action :add_solo
end

riak_config_riak "Riak config" do
  config_dir node["riak"]["config_dir"]
  logdir node["riak"]["logdir"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  riak_port_http node["riak"]["port_http"]
  action :config
end

riak_config_riakcs "Riak-cs config" do
  config_dir node["riak-cs"]["config_dir"]
  logdir node["riak-cs"]["logdir"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  stanchion_ip node["stanchion"]["ip"]
  stanchion_port node["stanchion"]["port"]
  s3_access s3_init_conf['access_key']
  s3_secret s3_init_conf['secret_key']
  action :config_solo
end

riak_config_stanchion "stanchion config" do
  config_dir node["stanchion"]["config_dir"]
  logdir node["stanchion"]["logdir"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  stanchion_ip node["stanchion"]["ip"]
  stanchion_port node["stanchion"]["port"]
  s3_access s3_init_conf['access_key']
  s3_secret s3_init_conf['secret_key']
  action :config_solo
end

riak_config_riakcs "Riak-cs create user" do
  s3cfg_file node["riak-cs"]["s3cfg_file"]
  action :create_user
end

riak_config_riakcs "Riak-cs set proxy" do
  proxy_conf node["riak-cs"]["proxy_conf"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  action :set_proxy_solo
end

riak_config_riakcs "Riak-cs create buckets" do
  action :create_buckets
end
