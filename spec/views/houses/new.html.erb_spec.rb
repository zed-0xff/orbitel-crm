require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/houses/new" do
  before(:each) do
    @house = assigns[:house] = House.new
    render 'houses/new'
  end

  it "should render"
end
