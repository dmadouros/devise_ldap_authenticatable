# encoding: utf-8
require 'devise'
require "net/ldap"

require 'devise_ldap_authenticatable/exception'
require 'devise_ldap_authenticatable/logger'
require 'devise_ldap_authenticatable/ldap/connection'

# Get ldap information from config/ldap.yml now
module Devise
  # Allow logging
  mattr_accessor :ldap_logger
  @@ldap_logger = true

  # A path to YAML config file or a Proc that returns a
  # configuration hash
  mattr_accessor :ldap_config

  mattr_accessor :ldap_auth_password_builder
  @@ldap_auth_password_builder = Proc.new() { |password| password}
end

# Add ldap_authenticatable strategy to defaults.
#
Devise.add_module(:ldap_authenticatable,
                  :route => :session, ## This will add the routes, rather than in the routes.rb
                  :strategy   => true,
                  :controller => :sessions,
                  :model  => 'devise_ldap_authenticatable/model')
