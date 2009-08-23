require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tickets/new" do
  before(:each) do
    @ticket = assigns[:ticket] = Ticket.new( :house => House.new )
    render 'tickets/new'
  end
  
  it "should render"
end
