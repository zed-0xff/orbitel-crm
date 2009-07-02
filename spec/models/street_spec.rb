require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Street do
  before(:each) do
    @valid_attributes = {
      :name => "value for name"
    }
    @street = Street.new @valid_attributes
  end

  it "should create a new instance given valid attributes" do
    @street.should be_valid
  end

  it "street with NULL name should not be valid" do
    @street.name = nil
    @street.should_not be_valid
  end

  it "street with empty name should not be valid" do
    @street.name = ''
    @street.should_not be_valid
  end

  it "street with name entire of spaces should not be valid" do
    @street.name = '     '
    @street.should_not be_valid
  end

  it "should capitalize street names on create" do
    @street.name = 'гоголя'
    @street.save!
    @street.name.should == 'Гоголя'
  end

  it "should strip 'ул.' on save" do
    @street.name = 'ул. гоголя'
    @street.save!
    @street.name.should == 'Гоголя'
  end

  describe "find_or_initialize_by_name" do
    it "should find existing street by name" do
      @street.name = 'гоголя'
      @street.save!
      Street.find_or_initialize_by_name('гоголя').should == @street
    end

    it "should initialize new street with name" do
      s = Street.find_or_initialize_by_name('пролетарская')
      s.should be_new_record
      s.name.should == 'пролетарская'
    end

    it "should strip 'ул.' on find" do
      @street.name = 'гоголя'
      @street.save!
      Street.find_or_initialize_by_name('ул. гоголя').should == @street
    end

    it "should strip 'ул.' on initialize" do
      s = Street.find_or_initialize_by_name('ул. пролетарская')
      s.should be_new_record
      s.name.should == 'пролетарская'
    end
  end
end
