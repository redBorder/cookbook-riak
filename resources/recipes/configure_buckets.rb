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

riak_config_riakcs "Riak-cs create buckets" do
  action :create_buckets
end
