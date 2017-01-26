#Riak attributes
default["riak"]["config_dir"] = "/etc/riak"
default["riak"]["logdir"] = "/var/log/riak"
default["riak"]["user"] = "riak"
default["riak"]["group"] = "riak"
default["riak"]["ip"] = node["ipaddress"] #Must be changed by internal IP attribute form rb-manager
default["riak"]["port"] = 8087
default["riak"]["port_http"] = 8098

#Riak-cs attributes
default["riak-cs"]["config_dir"] = "/etc/riak-cs"
default["riak-cs"]["logdir"] = "/var/log/riak-cs"
default["riak-cs"]["s3cfg_file"] = "/root/.s3cfg"
default["riak-cs"]["proxy_conf"] = "/etc/nginx/conf.d/riak-proxy.conf"
default["riak-cs"]["user"] = "riakcs"
default["riak-cs"]["group"] = "riak"
default["riak-cs"]["ip"] = node["ipaddress"] #Must be changed by internal IP attribute form rb-manager
default["riak-cs"]["port"] = 8088
default["riak-cs"]["cdomain"] = ""
default["riak-cs"]["version"] = "2.1.1"

#Stanchion attributes
default["stanchion"]["config_dir"] = "/etc/stanchion"
default["stanchion"]["logdir"] = "/var/log/stanchion"
default["stanchion"]["user"] = "stanchion"
default["stanchion"]["group"] = "riak"
default["stanchion"]["ip"] = node["ipaddress"] #Must be changed by internal IP attribute form rb-manager
default["stanchion"]["port"] = 8085
