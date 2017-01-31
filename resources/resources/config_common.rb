# Cookbook Name:: riak
# Resource:: config_common
#

actions :install, :add, :remove, :register, :deregister

attribute :user, :kind_of => String, :default => "riak"
attribute :group, :kind_of => String, :default => "riak"
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
