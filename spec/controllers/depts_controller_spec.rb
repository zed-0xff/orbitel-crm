require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeptsController do
  fixtures :users
  before do
    login_as :admin
  end

  #Delete these examples and add some real ones
  it "should use DeptsController" do
    controller.should be_an_instance_of(DeptsController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "should be successful" do
      get 'create'
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
      @dept = Dept.create! :name => 'd1'
    end

    it "GET should be forbidden"

    it "POST should be redirect" do
      post 'update', :id => @dept.id, :dept => {:name => 'ddd'}
      response.should be_redirect
    end
  end

  describe "GET 'destroy'" do
    it "should be successful" do
      get 'destroy'
      response.should be_success
    end
  end
end
