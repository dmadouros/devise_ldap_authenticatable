require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Users' do

  def should_be_validated(user, password, message = "Password is invalid")
    assert(user.valid_ldap_authentication?(password), message)
  end

  def should_not_be_validated(user, password, message = "Password is not properly set")
     assert(!user.valid_ldap_authentication?(password), message)
  end

  describe "With default settings" do
    before do
      default_devise_settings!
      reset_ldap_server!
    end

    describe "create a basic user" do
      before do
        @user = Factory.create(:user)
      end

      it "should check for password validation" do
        assert_equal(@user.email, "example.user@test.com")
        should_be_validated @user, "secret"
        should_not_be_validated @user, "wrong_secret"
        should_not_be_validated @user, "Secret"
      end
    end

    describe "change a LDAP password" do
      before do
        @user = Factory.create(:user)
      end

      it "should change password" do
        should_be_validated @user, "secret"
        @user.password = "changed"
        @user.change_password!("secret")
        should_be_validated @user, "changed", "password was not changed properly on the LDAP sevrer"
      end
    end

    describe "resetting LDAP password" do
      before do
        @user = Factory.create(:user)
      end

      it "should change password" do
        should_be_validated @user, "secret"
        # @user.password = "changed"
        @user.reset_password("changed", "changed")
        should_be_validated @user, "changed", "password was not changed properly on the LDAP sevrer"
      end
    end

    describe "use admin setting to bind" do
      before do
        @admin = Factory.create(:admin)
        @user = Factory.create(:user)
      end

      it "should description" do
        should_be_validated @admin, "admin_secret"
      end
    end
  end

  describe "using variants in the config file" do
    before do
      default_devise_settings!
      reset_ldap_server!
      ::Devise.ldap_config = Rails.root.join 'config', 'ldap_with_boolean_ssl.yml'
    end

    it "should not fail if config file has ssl: true" do
      Devise::LDAP::Connection.new
    end
  end
end
