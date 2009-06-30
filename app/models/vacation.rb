class Vacation < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user, :start_date, :end_date

  def validate
    Errors.add(:end_date, "must be greater than start_date") if self.end_date <= self.start_date
  end

  def include? date
    (self.start_date..self.end_date).include?(date)
  end

  def self.for_month year, month
    month_start = Date.civil(year, month)
    month_end   = Date.civil(year, month, -1)

    Vacation.all(
      :conditions => [
        "(end_date >= ? AND end_date <= ?) OR (start_date >= ? AND start_date <= ?)",
        month_start, month_end,
        month_start, month_end
      ],
      :order => 'start_date, end_date'
    )
  end
end
