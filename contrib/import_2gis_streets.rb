#!../script/runner
STDOUT.sync = true

IGNORES = [
  /[()]/,
  "дорога",
  "Керамзитный",
  "Чистое поле",
  "Чистополевая",
  /\dкм$/,
  / пос$/,
  / ст$/
]

require 'double_gis'
gis = DoubleGis.new

puts "[.] streets in db BEFORE import: #{Street.count}"
puts "[.] loading streets from 2gis.."
streets = gis.streets
puts "[.] loaded #{streets.size} streets from 2gis"

streets.sort.each do |name|
#  putc '.'
  if IGNORES.any?{ |i| name[i]}
    puts "[i] ignoring: #{name}"
    next
  end
  st = Street.find_or_initialize_by_name(name)
  if st.new_record?
    puts "[.] new street: #{name}"
    st.save!
  end
end
puts

puts "[.] streets in db AFTER  import: #{Street.count}"
