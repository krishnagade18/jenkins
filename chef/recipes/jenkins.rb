#
# Cookbook Name:: cic-jenkins
# Recipe:: default
#
# Copyright (C) 2016 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#
jenkins_keys = data_bag_item('packer', 'jenkins')

include_recipe 'jenkins::java'
include_recipe 'jenkins::master'
include_recipe 'golang'
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"
include_recipe "rbenv::rbenv_vars"
include_recipe "rbenv::ohai_plugin"
include_recipe 'packer'
include_recipe 'terraform'
include_recipe 'logstash'

node.default['packages'].each do |package|
  package package
end

require 'openssl'
require 'net/ssh'

key = OpenSSL::PKey::RSA.new(jenkins_keys['private_key'])
private_key = key.to_pem
public_key = "#{key.ssh_type} #{[key.to_blob].pack('m0')}"

node.run_state[:jenkins_private_key] = private_key

node.default['jenkins_plugins'].each do |plugin|
  jenkins_plugin plugin
end

node.default['ruby_versions'].each do |ruby|
  rbenv_ruby ruby
end

node.default['ruby_versions'].each do |ruby|
  rbenv_gem "bundler" do
    ruby_version ruby
  end
end
