# Cookbook Name:: riak
# Resource:: config_riakcs
#

actions :install, :config_solo, :config, :remove, :create_user, :set_proxy, :create_buckets

attribute :user, :kind_of => String, :default => "riakcs"
attribute :group, :kind_of => String, :default => "riak"
attribute :config_dir, :kind_of => String, :default => "/etc/riak-cs"
attribute :logdir, :kind_of => String, :default => "/var/log/riak-cs"
attribute :s3cfg_file, :kind_of => String, :default => "/root/.s3cfg"
attribute :proxy_conf, :kind_of => String, :default => "/etc/nginx/conf.d/riak-proxy.conf"

attribute :riak_ip, :kind_of => String, :default => "127.0.0.1"
attribute :riak_port, :kind_of => Fixnum, :default => 8087
attribute :riakcs_ip, :kind_of => String, :default => "127.0.0.1"
attribute :riakcs_port, :kind_of => Fixnum, :default => 8088
attribute :stanchion_ip, :kind_of => String, :default => "127.0.0.1"
attribute :stanchion_port, :kind_of => Fixnum, :default => 8085

attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
