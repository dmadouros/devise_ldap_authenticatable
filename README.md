Devise LDAP Authenticatable
===========================

Why this fork?
--------------
This fork changes a few lines to allow the admin binding to be set to the user trying to log in.

[![Gem Version](https://badge.fury.io/rb/devise_ldap_authenticatable.png)](http://badge.fury.io/rb/devise_ldap_authenticatable)
[![Code Climate](https://codeclimate.com/github/cschiewek/devise_ldap_authenticatable.png)](https://codeclimate.com/github/cschiewek/devise_ldap_authenticatable)
[![Dependency Status](https://gemnasium.com/cschiewek/devise_ldap_authenticatable.png)](https://gemnasium.com/cschiewek/devise_ldap_authenticatable)

Devise LDAP Authenticatable is a LDAP based authentication strategy for the [Devise](http://github.com/plataformatec/devise) authentication framework.

If you are building applications for use within your organization which require authentication and you want to use LDAP, this plugin is for you.

Devise LDAP Authenticatable works in replacement of Database Authenticatable. This devise plugin has not been tested with DatabaseAuthenticatable enabled at the same time. This is meant as a drop in replacement for DatabaseAuthenticatable allowing for a semi single sign on approach.

For a screencast with an example application, please visit: [http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html](http://random-rails.blogspot.com/2010/07/ldap-authentication-with-devise.html)

Prerequisites
-------------
 * devise ~> 3.0.0 (which requires rails ~> 4.0)
 * net-ldap ~> 0.6.0

Note: Rails 3.x / Devise 2.x has been moved to the 0.7 branch.  All 0.7.x gems will support Rails 3, where as 0.8.x will support Rails 4.

Usage
-----
In the Gemfile for your application:

    gem "devise_ldap_authenticatable"

To get the latest version, pull directly from github instead of the gem:

    gem "devise_ldap_authenticatable", :git => "git://github.com/dmadouros/devise_ldap_authenticatable.git"


Setup
-----
Run the rails generators for devise (please check the [devise](http://github.com/plataformatec/devise) documents for further instructions)

    rails generate devise:install
    rails generate devise MODEL_NAME

Configuration
-------------
In initializer  `config/initializers/devise.rb` :

* `ldap_logger` _(default: true)_
  * If set to true, will log LDAP queries to the Rails logger.
* `ldap_config` _(default: #{Rails.root}/config/ldap.yml)_
  * Where to find the LDAP config file. Commented out to use the default, change if needed.

Troubleshooting
--------------
**Using a "username" instead of an "email":** The field that is used for logins is the first key that's configured in the `config/initializers/devise.rb` file under `config.authentication_keys`, which by default is email. For help changing this, please see the [Railscast](http://railscasts.com/episodes/210-customizing-devise) that goes through how to customize Devise. Also, this [documentation](https://github.com/plataformatec/devise/wiki/How-To%3a-Allow-users-to-sign-in-using-their-username-or-email-address) from Devise can very helpful.

**SSL certificate invalid:** If you're using a test LDAP server running a self-signed SSL certificate, make sure the appropriate root certificate is installed on your system. Alternately, you may temporarily disable certificate checking for SSL by modifying your system LDAP configuration (e.g., `/etc/openldap/ldap.conf` or `/etc/ldap/ldap.conf`) to read `TLS_REQCERT never`.

Discussion Group
------------

For additional support, questions or discussions, please see the discussion forum on [Google Groups](https://groups.google.com/forum/#!forum/devise_ldap_authenticatable)

Development guide
------------

Devise LDAP Authenticatable uses a running OpenLDAP server to do automated acceptance tests. You'll need the executables `slapd`, `ldapadd`, and `ldapmodify`.

On OS X, this is available out of the box.

On Ubuntu, you can install OpenLDAP with `sudo apt-get install slapd ldap-utils`. If slapd runs under AppArmor, add an exception like this to `/etc/apparmor.d/local/usr.sbin.slapd` to let slapd read our configs.

    /path/to/devise_ldap_authenticatable/spec/ldap/** rw,$

To start hacking on `devise_ldap_authentication`, clone the github repository, start the test LDAP server, and run the rake test task:

    git clone https://github.com/cschiewek/devise_ldap_authenticatable.git
    cd devise_ldap_authenticatable
    bundle install

    # in a separate console or backgrounded
    ./spec/ldap/run-server

    bundle exec rake db:migrate # first time only
    bundle exec rake spec

References
----------
* [OpenLDAP](http://www.openldap.org/)
* [Devise](http://github.com/plataformatec/devise)
* [Warden](http://github.com/hassox/warden)

Released under the MIT license

Copyright (c) 2012 [Curtis Schiewek](https://github.com/cschiewek), [Daniel McNevin](https://github.com/dpmcnevin), [Steven Xu](https://github.com/cairo140)
