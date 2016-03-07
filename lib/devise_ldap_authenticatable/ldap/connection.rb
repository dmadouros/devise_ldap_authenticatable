module Devise
  module LDAP
    class Authenticate
      def initialize(ldap)
        @ldap = ldap
      end

      def call(login, password)
        DeviseLdapAuthenticatable::Logger.send("Authorizing user: #{login}")
        @ldap.auth(login, password)

        if @ldap.bind
          return true
        else
          DeviseLdapAuthenticatable::Logger.send("Cannot bind to LDAP user: #{login}")
          return false
        end
      end

      private

      attr_reader :ldap
    end

    class ChangePassword
      def initialize(ldap)
        @ldap = ldap
      end

      def call(login, new_password)
        operations = [
          [:replace, :userpassword, Net::LDAP::Password.generate(:sha, new_password)]
        ]

        DeviseLdapAuthenticatable::Logger.send("Modifying user: #{login}")
        unless ldap.modify(:dn => login, :operations => operations)
          DeviseLdapAuthenticatable::Logger.send("Cannot change password of LDAP user: #{login}")
          raise DeviseLdapAuthenticatable::LdapException, "Cannot change password of LDAP user: #{login}"
        end
      end

      private

      attr_reader :ldap
    end

    class Connection
      def initialize
        @config = YAML.load(File.read(::Devise.ldap_config || "#{Rails.root}/config/ldap.yml"))[Rails.env]

        @ldap = Net::LDAP.new
        ldap.host = config["host"]
        ldap.port = config["port"]
        ldap.base = config["base"]
      end

      def authorized?(login, password)
        Authenticate.new(ldap).call(build_username(login), password)
      end

      def reset_password(login, new_password)
        DeviseLdapAuthenticatable::Logger.send("Authorizing admin")
        ldap.auth(config["admin_user"], config["admin_password"])

        unless ldap.bind
          DeviseLdapAuthenticatable::Logger.send("Cannot bind to admin LDAP user")
          raise DeviseLdapAuthenticatable::LdapException, "Cannot connect to admin LDAP user"
        end

        ChangePassword.new(ldap).call(build_username(login), new_password)
      end

      def change_password(login, current_password, new_password)
        DeviseLdapAuthenticatable::Logger.send("Authorizing user: #{login}")
        ldap.auth(build_username(login), current_password)

        unless ldap.bind
          DeviseLdapAuthenticatable::Logger.send("Cannot bind to LDAP user: #{login}")
          raise DeviseLdapAuthenticatable::LdapException, "Cannot connect to LDAP user: #{login}"
        end

        ChangePassword.new(ldap).call(build_username(login), new_password)
      end

      private

      attr_reader :config, :ldap

      def build_username(login)
        "#{config["attribute"]}=#{login},#{config["base"]}"
      end
    end
  end
end
