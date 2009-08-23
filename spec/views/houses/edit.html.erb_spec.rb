require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/houses/edit" do
  before(:each) do
    @house = assigns[:house] = House.new
    render 'houses/edit'
  end
  
  it "should render"
end
