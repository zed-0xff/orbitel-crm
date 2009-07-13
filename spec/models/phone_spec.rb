require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Phone do
  describe "canonicalize()" do
    examples = ActiveSupport::OrderedHash.new
    examples[230546]          = 83522230546
    examples[89125790778]     = 89125790778
    examples['23 29 36']      = 83522232936
    examples['(343) 2626888'] = 83432626888
    examples['(343)3721520']  = 83433721520
    examples['(3452) 200996'] = 83452200996
    examples['(3522) 422520'] = 83522422520
    examples[411089]          = 83522411089
    examples[2411089]         = 83522411089
    examples[22411089]        = 83522411089
    examples[522411089]       = 83522411089
    examples[3522411089]      = 83522411089
    examples[83522411089]     = 83522411089
    examples['+79226700446']  = 89226700446
    examples['(495) 9371231'] = 84959371231

    examples.each do |k,v|
      it "should process \"#{k}\"" do
        Phone.canonicalize(k).to_s.should == v.to_s
      end
    end
  end
end
