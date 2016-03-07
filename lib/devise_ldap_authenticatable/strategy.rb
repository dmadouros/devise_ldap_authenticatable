require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable

      # Tests whether the returned resource exists in the database and the
      # credentials are valid.  If the resource is in the database and the credentials
      # are valid, the user is authenticated.  Otherwise failure messages are returned
      # indicating whether the resource is not found in the database or the credentials
      # are invalid.
      def authenticate!
        resource = mapping.to.find_for_ldap_authentication(authentication_hash.merge(password: password))
        return fail(:invalid) unless resource.present?

        if validate(resource) { resource.valid_ldap_authentication?(password) }
          success!(resource)
        else
          return fail(:invalid) # Invalid credentials
        end
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
