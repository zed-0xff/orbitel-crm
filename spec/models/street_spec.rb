require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Street do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
    @street = Street.new @valid_attributes
  end

  it "should create a new instance given valid attributes" do
    @street.should be_valid
  end

  it "street with NULL name should not be valid" do
    @street.name = nil
    @street.should_not be_valid
  end

  it "street with empty name should not be valid" do
    @street.name = ''
    @street.should_not be_valid
  end

  it "street with name entire of spaces should not be valid" do
    @street.name = '     '
    @street.should_not be_valid
  end
end
