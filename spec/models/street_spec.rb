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

  describe "smart_find()" do
    it "should find street by exact name" do
      s = Street.create! :name => 'Ленина'
      Street.smart_find('ленина').should == s
    end

    it "should find street prefixed with 'ул.'" do
      s = Street.create! :name => 'Ленина'
      Street.smart_find('ул.ленина').should == s
      Street.smart_find('ул. ленина').should == s
      Street.smart_find(' ул.  ленина ').should == s
    end

    it "should find street by partial name if only one match" do
      s = Street.create! :name => 'проспект голикова'
      Street.smart_find('голикова').should == s
    end

    it "should NOT find street by partial name if many matches" do
      Street.create! :name => 'проспект голикова'
      Street.create! :name => 'улица голикова'
      Street.smart_find('голикова').should be_nil
    end

    it "should find by shortened name if only one match" do
      s = Street.create! :name => 'карла маркса'
      Street.smart_find('к.маркса').should == s
      Street.smart_find('к. маркса').should == s
      Street.smart_find('  к.   маркса  ').should == s
      Street.smart_find('к-маркса').should == s
    end

    it "should find by shortened name if only one match #2" do
      s = Street.create! :name => 'карла-маркса'
      Street.smart_find('к.маркса').should == s
      Street.smart_find('к. маркса').should == s
      Street.smart_find('  к.   маркса  ').should == s
      Street.smart_find('к-маркса').should == s
      Street.smart_find('к.-маркса').should == s
    end

    it "should NOT find by shortened name if many matches" do
      Street.create! :name => 'карла маркса'
      Street.create! :name => 'коли маркса'
      Street.smart_find('к.маркса').should be_nil
      Street.smart_find('к. маркса').should be_nil
      Street.smart_find('  к.   маркса  ').should be_nil
      Street.smart_find('к-маркса').should be_nil
    end

    it "should NOT find by shortened name if many matches #2" do
      Street.create! :name => 'карла-маркса'
      Street.create! :name => 'коли маркса'
      Street.smart_find('к.маркса').should be_nil
      Street.smart_find('к. маркса').should be_nil
      Street.smart_find('  к.   маркса  ').should be_nil
      Street.smart_find('к-маркса').should be_nil
    end

    it "should find by shortened name if words are in reverse order" do
      s = Street.create! :name => 'Машиностроителей проспект'
      Street.smart_find('пр. Машиностроителей.').should == s
    end

    it "should match alias if only one match" do
      s = Street.create! :name => 'Васильева'
      s.add_alias 'С.Васильева'
      s.save!
      Street.smart_find('С.Васильева').should == s
    end

    it "should not match alias if many matches" do
      s = Street.create! :name => 'Васильева'
      s.add_alias 'С.Васильева'
      s.save!
      s = Street.create! :name => 'Васильева (dup)'
      s.add_alias 'С.Васильева'
      s.save!
      Street.smart_find('С.Васильева').should be_nil
    end

    it "should find by words in reverse order" do
      s = Street.create! :name => 'Больничная 7-я'
      Street.smart_find('7-я Больничная' ).should == s
    end
  end
end
