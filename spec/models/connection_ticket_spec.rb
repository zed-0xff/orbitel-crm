require 'spec_helper'

describe ConnectionTicket do
  DYNAMIC_ATTRS = %w'vlan ip router_status billing_status created_at_router created_at_billing tarif_ext_id manager'

  DYNAMIC_ATTRS.each do |da|
    describe "should have dynamic attr #{da}" do
      [ rand(999999999),
        "xxx#{rand}",
        rand
      ].each do |value|
        it "get before set - #{value.class}" do
          ticket = ConnectionTicket.new
          ticket.send(da).should be_nil
          ticket.send("#{da}=",value)
          ticket.send(da).should == value
          ticket.custom_info.should == {da.to_sym => value}
        end

        it "get after set - #{value.class}" do
          ticket = ConnectionTicket.new
          ticket.send("#{da}=",value)
          ticket.send(da).should == value
          ticket.custom_info.should == {da.to_sym => value}
        end

        it "in constructor" do
          ticket = ConnectionTicket.new(da => value)
          ticket.custom_info.should == {da.to_sym => value}
          ticket.send(da).should == value
        end
      end
    end
  end

  it "should raise error on unknown attr in contructor" do
    lambda{
      ConnectionTicket.new('asdjkl' => 1234)
    }.should raise_error
    lambda{
      ConnectionTicket.new(:asdjkl  => 1234)
    }.should raise_error
  end

  it "should raise error on unknown attr set" do
    ticket = ConnectionTicket.new
    lambda{
      ticket.askldjlak = 12390
    }.should raise_error
    lambda{
      ticket.askldjlak
    }.should raise_error
  end
end
