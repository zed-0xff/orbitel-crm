require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Customer do
  describe "address setter" do
    examples = {}
    examples['ул. М. Горького, 153 - 57'] = ['М.Горького',153,57]
    examples['ул. Станционная 24-16']     = ['Станционная',24,16]
    examples['г.Курган,ул. Ленина, 5']    = ['Ленина',5]
    examples['ул. 7-я Больничная, 36-25'] = ['7-я Больничная',36,25]
    examples['Ул. 7-я Больничная, 36-25'] = ['7-я Больничная',36,25]
    examples['г. Курган, пр. Машиностроителей, 26Г'] = ['Машиностроителей','26г']
    examples['г Курган, пр. Машиностроителей, 26Г'] = ['Машиностроителей','26г']
    examples['Пушкина 55 кв.8']           = ['Пушкина', 55, 8]
    examples['К.Мяготина 119 офис 100']   = ['К.Мяготина', 119, 100]
    examples['г. Курган, ул. Пролетарская, 80, каб.13']   = ['Пролетарская',80,13]
    examples['г. Курган, ул. Дзержинского 52 - 2'] = %w'Дзержинского 52 2'
    examples['г. Курган, ул. Дзержинского, 52 - 2'] = %w'Дзержинского 52 2'
    examples['г. Курган, ул. Станционная, 64а-309'] = %w'Станционная 64а 309'
    examples['1 мая 21 кв.197']           = ['1 мая', 21, 197]
    examples['640000, г.Курган, ул.Пичугина, 38'] = %w'Пичугина 38'
    examples['640652, г.Курган, ул. Куйбышева, 87'] = %w'Куйбышева 87'
    examples['Пичугина 9, оф 222'] = %w'Пичугина 9 222'

    examples.each do |k,v|
      it "should parse #{k.to_s.inspect}" do
        c = Customer.new
        Street.create :name => v[0]
        c.address = k
        c.house.should be_instance_of(House)
        if v[2]
          [c.house.street.name, c.house.number, c.flat].map(&:to_s).should == v.map(&:to_s)
        else
          [c.house.street.name, c.house.number.to_s].should == v.map(&:to_s)
        end
      end
    end
  end
end
