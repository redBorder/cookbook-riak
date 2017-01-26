# Cookbook Name:: riak
# Resource:: config_riak
#

actions :config, :remove

attribute :user, :kind_of => String, :default => "riak"
attribute :group, :kind_of => String, :default => "riak"
attribute :config_dir, :kind_of => String, :default => "/etc/riak"
attribute :logdir, :kind_of => String, :default => "/var/log/riak"

attribute :riak_ip, :kind_of => String, :default => "127.0.0.1"
attribute :riak_port, :kind_of => Fixnum, :default => 8087
attribute :riak_port_http, :kind_of => Fixnum, :default => 8098
