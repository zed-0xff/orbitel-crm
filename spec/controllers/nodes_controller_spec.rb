require 'spec_helper'

describe NodesController do

  #Delete these examples and add some real ones
  it "should use NodesController" do
    controller.should be_an_instance_of(NodesController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end
  end
end
