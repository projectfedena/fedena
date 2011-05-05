class TimetableWeekDay < ActiveRecord::Base
  has_many :timetable_entries
end