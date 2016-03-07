require 'devise_ldap_authenticatable/strategy'

module Devise
  module Models
    # LDAP Module, responsible for validating the user credentials via LDAP.
    #
    # Examples:
    #
    #    User.authenticate('email@test.com', 'password123')  # returns authenticated user or nil
    #    User.find(1).valid_password?('password123')         # returns true/false
    #
    module LdapAuthenticatable
      extend ActiveSupport::Concern

      included do
        attr_reader :current_password, :password
        attr_accessor :password_confirmation
      end

      def valid_ldap_authentication?(password)
        Devise::LDAP::Connection.new.authorized?(login_with, password)
      end

      def change_password!(current_password)
        raise "Need to set new password first" if password.blank?

        Devise::LDAP::Connection.new.change_password(login_with, current_password, password)
      end

      def reset_password(new_password, new_password_confirmation)
        if new_password.present? && new_password == new_password_confirmation
          Devise::LDAP::Connection.new.reset_password(login_with, new_password)
        end

        clear_reset_password_token if valid?

        save
      end

      def login_with
        @login_with ||= Devise.mappings.find {|k,v| v.class_name == self.class.name}.last.to.authentication_keys.first

        self[@login_with]
      end

      def password=(new_password)
        @password = new_password

        if defined?(password_digest) && @password.present? && respond_to?(:encrypted_password=)
          self.encrypted_password = password_digest(@password)
        end
      end

      module ClassMethods
        def find_for_ldap_authentication(attributes={})
          auth_key = self.authentication_keys.first
          return nil unless attributes[auth_key].present?

          auth_key_value = (self.case_insensitive_keys || []).include?(auth_key) ? attributes[auth_key].downcase : attributes[auth_key]
      	  auth_key_value = (self.strip_whitespace_keys || []).include?(auth_key) ? auth_key_value.strip : auth_key_value

          where(auth_key => auth_key_value).first
        end
      end
    end
  end
end
