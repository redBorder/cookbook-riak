#
# Cookbook Name:: riak
# Recipe:: default_solo
#
# 2017, redborder
#
# AFFERO GENERAL PUBLIC LICENSE V3
#

include_recipe 'riak::configure_solo'
#include_recipe 'riak::configure_solo'
include_recipe 'riak::configure_buckets'
