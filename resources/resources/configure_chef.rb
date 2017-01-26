# Cookbook Name:: riak
# Resource:: configure_chef
#

actions :configure, :upload_cookbooks

attribute :erchef_conf, :kind_of => String, :default => "/var/opt/opscode/opscode-erchef/sys.config"
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
