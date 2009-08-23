require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketsController do
  fixtures :users, :streets

  before do
    login_as :admin
  end

  #Delete these examples and add some real ones
  it "should use TicketsController" do
    controller.should be_an_instance_of(TicketsController)
  end


  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "'create'" do
    it "GET should be forbidden"
    it "POST should create a new ticket and redirect to it" do
      post 'create', :ticket => {
        :title => "title",
        "house_attributes"=>{
          "number"=>"1", 
          "street"=>"Гоголя"
        }
      }
      assigns[:ticket].should_not be_nil
      assigns[:ticket].should be_valid
      response.should be_redirect
      response.should redirect_to( ticket_path( assigns[:ticket] ) )
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "should be successful" do
      get 'update'
      response.should be_success
    end
  end
end
