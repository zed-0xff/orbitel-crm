require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Default Admin account" do
  before do
    User.delete_all
    @yaml = YAML.load_file "#{RAILS_ROOT}/spec/fixtures/default_admin.yml"
  end

  it "should be created successfully" do
    lambda {
      lambda {
        Admin.create! @yaml['admin']
      }.should change(Admin,:count).by(1)
    }.should change(User,:count).by(1)
  end

  it "should authorize successfully" do
    Admin.create! @yaml['admin']
    admin = Admin.first
    User.authenticate(@yaml['admin']['login'], @yaml['admin']['password']).should == admin
  end
end
