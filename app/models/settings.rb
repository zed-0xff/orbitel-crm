class Settings < ActiveRecord::Base
  def self.[] key
    YAML::load(find_by_key(key).try(:value) || nil.to_yaml)
  end

  def self.[]= key,value
    r = find_or_initialize_by_key(key)
    r.value = value.to_yaml
    r.save!
    value
  end
end
