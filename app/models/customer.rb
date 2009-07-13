class Customer < ActiveRecord::Base
  has_many :phones

  def initialize *args
    if args.first.is_a?(Hash)
      phones   = args.first.delete(:phones)
      phones ||= args.first.delete(:phone).to_a
      if phones.any?
        args.first[:phones] = Phone.from_array_or_string(phones)
      end
    end
    super
  end

  def self.find_by_phone phone_number
    Phone.find_by_number(phone_number).try(:customer)
  end
end
