class Ticket < ActiveRecord::Base
  belongs_to :house
  belongs_to :created_by,   :class_name => 'User'

  accepts_nested_attributes_for :house

  default_scope :order => 'created_at DESC'

  CONTACT_TYPE_UR  = 1
  CONTACT_TYPE_FIZ = 2

  # create a house/street if needed, or find an existing by their attributes
  def initialize *args
    if args.first.is_a?(Hash) && args.first[:house].is_a?(Hash)
      house_attrs = args.first[:house]

      street = if house_attrs[:street_id]
        Street.find house_attrs[:street_id]
      elsif house_attrs[:street]
        Street.find_or_initialize_by_name house_attrs[:street]
      else
        Street.new
      end

      house = if street.new_record?
        House.new(
          :number => house_attrs[:number],
          :street => street
        )
      else
        House.find_or_initialize_by_street_id_and_number(
          street.id,
          house_attrs[:number]
        )
      end

      args.first[:house] = house
    end
    super *args
  end
end
