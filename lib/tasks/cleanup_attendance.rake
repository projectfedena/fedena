namespace :fedena do
  desc 'Prepare db for new timetable system'
  task :cleanup_attendance => :environment do
    Attendance.delete_all
    ClassTiming.delete_all
    Weekday.delete_all
    TimetableEntry.delete_all
  end
end