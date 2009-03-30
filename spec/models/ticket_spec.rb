require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Ticket do
  before(:each) do
    @valid_attributes = {
      :type => "value for type",
      :created_by_id => 1,
      :assignee_id => 1,
      :house_id => 1,
      :status_id => 1,
      :description => "value for description",
      :contact => "value for contact"
    }
  end

  it "should create a new instance given valid attributes" do
    Ticket.create!(@valid_attributes)
  end
end
