#
# Cookbook Name:: riak
# Recipe:: configure
#
# 2017, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

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
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  stanchion_ip node["stanchion"]["ip"]
  stanchion_port node["stanchion"]["port"]
  cdomain node["redborder"]["cdomain"]
  action :config
end

riak_config_stanchion "stanchion config" do
  config_dir node["stanchion"]["config_dir"]
  logdir node["stanchion"]["logdir"]
  stanchion_ip node["stanchion"]["ip"]
  stanchion_port node["stanchion"]["port"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  riak_ip node["riak"]["ip"]
  riak_port node["riak"]["port"]
  action :config
end

riak_config_riakcs "Riak-cs create user" do
  s3cfg_file node["riak-cs"]["s3cfg_file"]
  action :create_user
end

riak_config_riakcs "Riak-cs set proxy" do
  proxy_conf node["riak-cs"]["proxy_conf"]
  riakcs_ip node["riak-cs"]["ip"]
  riakcs_port node["riak-cs"]["port"]
  cdomain node["redborder"]["cdomain"]
  action :set_proxy
end

riak_config_riakcs "Riak-cs create buckets" do
  action :create_buckets
end
