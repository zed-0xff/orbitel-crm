require 'spec_helper'

describe Node do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :external_id => "value for external_id",
      :parent_id => ,
      :nodetype => "value for nodetype"
    }
  end

  it "should create a new instance given valid attributes" do
    Node.create!(@valid_attributes)
  end
end
