#
# Cookbook Name:: riak
# Recipe:: configure
#
# 2017, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

# Load keys from s3_secrets data bag
#s3_databag = Chef::DataBagItem.load("passwords", "s3") rescue s3_secrets = {}

nginx_config "config" do
  action :add
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
  #s3_access GET FROM DATA BAG
  #s3_secret GET FROM DATA BAG
  action :config
end

riak_config_riakcs "Riak-cs set proxy" do
  proxy_conf node["riak-cs"]["proxy_conf"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  action :set_proxy
end
