require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/houses/check" do
  before(:each) do
    render 'houses/check'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/houses/check])
  end
end
