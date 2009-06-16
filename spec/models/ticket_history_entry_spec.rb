require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketHistoryEntry do
  before(:each) do
    @valid_attributes = {
      :ticket_id => 1,
      :created_at => Time.now,
      :user_id => 1,
      :old_status => 1,
      :new_status => 1,
      :comment => "value for comment"
    }
  end

  it "should create a new instance given valid attributes" do
    TicketHistoryEntry.create!(@valid_attributes)
  end
end
