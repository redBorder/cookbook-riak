# Cookbook Name:: riak
# Resource:: config_stanchion
#

actions :config, :remove

attribute :user, :kind_of => String, :default => "stanchion"
attribute :group, :kind_of => String, :default => "riak"
attribute :config_dir, :kind_of => String, :default => "/etc/stanchion"
attribute :logdir, :kind_of => String, :default => "/var/log/stanchion"

attribute :stanchion_ip, :kind_of => String, :default => "127.0.0.1"
attribute :stanchion_port, :kind_of => Fixnum, :default => 8085
attribute :riakcs_ip, :kind_of => String, :default => "127.0.0.1"
attribute :riakcs_port, :kind_of => Fixnum, :default => 8088
attribute :riak_ip, :kind_of => String, :default => "127.0.0.1"
attribute :riak_port, :kind_of => Fixnum, :default => 8087
