#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
class Timetable < ActiveRecord::Base
  has_many :timetable_entries , :dependent=>:destroy
  validates_presence_of :start_date
  validates_presence_of :end_date
  default_scope :order=>'start_date ASC'

  def self.tte_for_range(batch,date,subject)
    unless subject.elective_group_id.nil?
      subject=subject.elective_group.subjects.first
    end
    range=register_range(batch,date)
    holidays=batch.holiday_event_dates
    entries = TimetableEntry.find(:all,:joins=>[:timetable, :weekday, :class_timing],:include=>:weekday,:conditions=>["((? BETWEEN start_date AND end_date) OR (? BETWEEN start_date AND end_date) OR (start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)) AND timetable_entries.subject_id = ? AND timetable_entries.batch_id = ? AND class_timings.is_deleted = false AND weekdays.is_deleted = false",range.first,range.last,range.first,range.last,range.first,range.last,subject.id,batch.id])
    #    entries = TimetableEntry.find(:all,:joins=>:timetable,:include=>:weekday,:conditions=>["(timetables.start_date <= ? OR timetables.end_date >= ?) AND timetable_entries.subject_id = ? AND timetable_entries.batch_id = ?",range.first,range.last,subject.id,batch.id])
    timetable_ids=entries.collect(&:timetable_id).uniq
    hsh2=ActiveSupport::OrderedHash.new
    unless timetable_ids.nil?
      timetables=find(timetable_ids)
      hsh = ActiveSupport::OrderedHash.new
      entries_hash = entries.group_by(&:timetable_id)
      entries_hash.each do |k,val|
        hsh[k]=val.group_by(&:day_of_week)
      end
      timetables.each do |tt|
        ([tt.start_date,range.first].max..[tt.end_date,range.last].min).each do |d|
          hsh2[d]=hsh[tt.id][d.wday]
        end
      end
    end
    holidays.each do |h|
      hsh2.delete(h)
    end
    hsh2
  end

  def self.tte_for_the_day(batch,date)
    entries = TimetableEntry.find(:all,:joins=>[:timetable, :class_timing, :weekday],:conditions=>["(timetables.start_date <= ? AND timetables.end_date >= ?)  AND timetable_entries.batch_id = ? AND class_timings.is_deleted = false AND weekdays.is_deleted = false",date,date,batch.id], :order=>"class_timings.start_time")
    if entries.empty?
      today=[]
    else
      today=entries.select{|a| a.day_of_week==date.wday}
    end
    today
  end

  def self.tte_for_the_weekday(batch,day)
    date=Date.today
    entries = TimetableEntry.find(:all,:joins=>[:timetable, :class_timing, :weekday],:conditions=>["(timetables.start_date <= ? AND timetables.end_date >= ?)  AND timetable_entries.batch_id = ? AND class_timings.is_deleted = false AND weekdays.is_deleted = false",date,date,batch.id], :order=>"class_timings.start_time",:include=>[:employee,:class_timing,:subject])
    if entries.empty?
      today=[]
    else
      today=entries.select{|a| a.day_of_week==day}
    end
    today
  end

  def self.employee_tte(employee,date)
    subjects = employee.subjects.map {|sub| sub.elective_group_id.nil? ? sub : sub.elective_group.subjects.first}
    entries = TimetableEntry.find(:all,:joins=>[:timetable, :class_timing, :weekday],:conditions=>["(timetables.start_date <= ? AND timetables.end_date >= ?) AND timetable_entries.subject_id in (?) AND class_timings.is_deleted = false AND weekdays.is_deleted = false",date,date,subjects], :order=>"class_timings.start_time")
    if entries.empty?
      today=[]
    else
      today=entries.select{|a| a.day_of_week==date.wday}
    end
    today
  end

  def self.subject_tte(subject_id,date)
    subject=Subject.find(subject_id)
    unless subject.elective_group.nil?
      subject=subject.elective_group.subjects.first
    end
    entries = TimetableEntry.find(:all,:joins=>[:timetable, :class_timing, :weekday],:conditions=>["(timetables.start_date <= ? AND timetables.end_date >= ?)  AND timetable_entries.subject_id = ? AND class_timings.is_deleted = false AND weekdays.is_deleted = false",date,date,subject.id])
    if entries.empty?
      today=[]
    else
      today=entries.select{|a| a.day_of_week==date.wday}
    end
    today
  end

  def self.register_range(batch,date)
    start=[]
    start<<batch.start_date.to_date
    start<<date.beginning_of_month.to_date
    start<<find(:first,:select=>:start_date,:order=>:start_date).start_date.to_date
    stop=[]
    stop<<batch.end_date.to_date
    stop<<date.end_of_month.to_date
    stop<<find(:last,:select=>:end_date,:order=>:end_date).end_date.to_date
    range=(start.max..stop.min).to_a - batch.holiday_event_dates
  end
end