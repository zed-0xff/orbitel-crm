require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DoubleGis do
  it "should use default_host" do
    host = "dhost#{rand}"
    DoubleGis.default_host = host
    DoubleGis.new.host.should == host
  end

  it "should use default_port" do
    port = rand(65536)
    DoubleGis.default_port = port
    DoubleGis.new.port.should == port
  end

  it "should have default debug set to false" do
    DoubleGis.new.debug.should be_false
  end
end
