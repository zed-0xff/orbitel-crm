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

  describe "soa2numbers()" do
    examples = ActiveSupport::OrderedHash.new
    examples[89125790778] = 89125790778
    examples["89091712200, 89048122325"]      = %w'89091712200 89048122325'
    examples["с.т. 89058511972, р.т. 422649"] = %w'89058511972 83522422649'
    examples["с.т. 624222, д.т. 455898. р.т. 416047"] = %w'83522624222 83522455898 83522416047'
    examples["Сов. 414110, +79091490033 Андр. Владимирович"] = %w'83522414110 89091490033'
    examples["с. 89630096555, р. 443904, д. 500681"] = %w'89630096555 83522443904 83522500681'
    examples["р.534251; 454300; +79088332413"] = %w'83522534251 83522454300 89088332413'
    examples["89634377629, 576029"] = %w'89634377629 83522576029'
    examples["89730038861 (привет)"] = 89730038861
    examples["8 951 265 92 17"]      = 89512659217
    examples["89221603122, 89128374171, (343) 3789977"] = %w'89221603122 89128374171 83433789977'
    examples["89129780101, (8351)7299299"] = %w'89129780101 83517299299'
    examples["+79634355444"] = %w'89634355444'
    examples["(83522) 444211, 421538 (бух.)"] = %w'83522444211 83522421538'
    examples["(343) 3781178, 3789900, (3522) 530732"] = %w'83433781178 83523789900 83522530732'

    examples.each do |k,v|
      it "should process \"#{k}\"" do
        v = [v] unless v.is_a?(Array)
        Phone.soa2numbers(k).should == v.map(&:to_i)
      end
    end
  end
end
