require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/depts/index" do
  before(:each) do
    @depts = assigns[:depts] = []
    render 'depts/index'
  end
  
  it "should list depts"
end
