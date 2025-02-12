class RestDay < ActiveRecord::Base
  unloadable
  
  #attr_accessible :day, :description #deprecated, replaced by strong parameter

  default_scope { order("#{RestDay.table_name}.day ASC") }
  
  scope :in_year, lambda{|year| where(:day => year.beginning_of_year..year.end_of_year)}
  scope :between, lambda{|day1, day2| where(:day => day1..day2)}

  validates_presence_of :day
  validates_length_of :description, :maximum => 200, :allow_nil => true
  validates_presence_of :work_type

  class << self
    def rest_day?(date)
      date = Date.parse(date) unless date.is_a?(Date)
      !!rest_days.detect { |d| d.day == date && d.work_type == 0}
    end

    def rest_days
      @rest_days ||= all
    end

    def clear!
      @rest_days = nil
    end

    def work_day?(date)
      date = Date.parse(date) unless date.is_a?(Date)
      !!rest_days.detect { |d| d.day == date && d.work_type == 1}
    end

  end
end
