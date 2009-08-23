require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HousesController do
  fixtures :users

  before do
    login_as :admin
  end

  #Delete these examples and add some real ones
  it "should use HousesController" do
    controller.should be_an_instance_of(HousesController)
  end


  describe "GET 'check'" do
    it "should be successful" do
      get 'check'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end

  describe "'update'" do
    before do
      @house = House.create! :street => Street.new(:name => 's1'), :number => 1
    end

    it "POST should be redirect" do
      post 'update', :id => @house.id, :house => { :number => 111 }
      response.should be_redirect
    end

    it "POST should update house attrs"

    it "GET should be forbidden"
  end
end
