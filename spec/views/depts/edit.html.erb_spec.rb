require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/depts/edit" do
  before(:each) do
    @dept = assigns[:dept] = Dept.new
    render 'depts/edit'
  end
  
  it "should render"
end
