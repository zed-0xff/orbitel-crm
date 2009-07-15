require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe House do
  before(:each) do
    @valid_attributes = {
      :street => Street.new(:name => 'Гоголя'),
      :number => "value for number"
    }
  end

  it "should create a new instance given valid attributes" do
    House.create!(@valid_attributes)
  end

  describe "from_address()" do
  end
end
