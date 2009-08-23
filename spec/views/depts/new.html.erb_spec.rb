require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/depts/new" do
  before(:each) do
    @dept = assigns[:dept] = Dept.new
    render 'depts/new'
  end
  
  it "should render"
end
