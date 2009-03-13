require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/welcome/index" do
  before(:each) do
    render 'welcome/index'
  end
  
  it "should welcome" do
    response.should have_text(/Welcome/)
  end
end
