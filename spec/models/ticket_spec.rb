require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Ticket do
  before(:each) do
    @valid_attributes = {
      :created_by_id => 1,
      :assignee_id => 1,
      :house_id => 1,
      :notes => "value for notes",
      :contact_info => "value for contact info"
    }
  end

  it "should create a new instance given valid attributes" do
    Ticket.create!(@valid_attributes)
  end

  it "newly created ticket status should be ST_NEW" do
    t = Ticket.create!(@valid_attributes)
    t.status.should == Ticket::ST_NEW
  end

  describe "should create house if it not exists AND" do
    it "should create street if it not exists" do
      attrs = @valid_attributes
      attrs.delete(:house_id)
      attrs[:house] = {
        :number    => 1,
        :street    => 'Test Street#2'
      }

      ticket = nil

      lambda{
        lambda{
          lambda{
            ticket = Ticket.create! attrs
          }.should change(Ticket, :count).by(1)
        }.should change(House, :count).by(1)
      }.should change(Street, :count).by(1)

      ticket.reload
      ticket.house.reload
      ticket.house.street.reload

      ticket.house.street.name.should == 'Test Street#2'
      ticket.house.number.should == '1'
    end

    it "should NOT create street with blank name" do
      attrs = @valid_attributes
      attrs.delete(:house_id)
      attrs[:house] = {
        :number    => 1,
        :street    => ''
      }

      ticket = nil

      lambda{
        lambda{
          lambda{
            ticket = Ticket.create attrs
          }.should_not change(Ticket, :count).by(1)
        }.should_not change(House, :count).by(1)
      }.should_not change(Street, :count).by(1)

      ticket.should_not be_valid
    end

    it "should use existing street" do
      street = Street.create! :name => 'TestStreet'

      attrs = @valid_attributes
      attrs.delete(:house_id)
      attrs[:house] = {
        :number    => 1,
        :street    => street.name
      }

      ticket = nil

      lambda{
        lambda{
          lambda{
            ticket = Ticket.create! attrs
          }.should change(Ticket, :count).by(1)
        }.should change(House, :count).by(1)
      }.should_not change(Street, :count)

      street.reload
      ticket.house.reload

      ticket.house.street.should == street
      ticket.house.number.should == '1'
    end
  end

  it "should use existing house when street name given" do
    street = Street.create! :name => 'TestStreet'
    house  = House.create! :number => 1, :street_id => street.id

    attrs = @valid_attributes
    attrs.delete(:house_id)
    attrs[:house] = {
      :number    => 1,
      :street    => street.name
    }

    ticket = nil

    lambda{
      lambda{
        ticket = Ticket.create! attrs
      }.should change(Ticket, :count).by(1)
    }.should_not change(House, :count)

    house.reload

    ticket.house.should == house
    house.number.should == '1'
    house.street_id.should == street.id
  end

  it "should use existing house when street_id given" do
    street = Street.create! :name => 'TestStreet'
    house = House.create! :number => 1, :street_id => street.id
    attrs = @valid_attributes
    attrs.delete(:house_id)
    attrs[:house] = {
      :number    => 1,
      :street_id => street.id
    }

    ticket = nil

    lambda{
      lambda{
        ticket = Ticket.create! attrs
      }.should change(Ticket, :count).by(1)
    }.should_not change(House, :count)

    house.reload

    ticket.house.should == house
    house.number.should == '1'
    house.street_id.should == street.id
  end
end
