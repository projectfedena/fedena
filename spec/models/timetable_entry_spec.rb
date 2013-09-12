require 'spec_helper'

describe TimetableEntry do
  it { should belong_to(:timetable) }
  it { should belong_to(:batch) }
  it { should belong_to(:class_timing) }
  it { should belong_to(:subject) }
  it { should belong_to(:employee) }
  it { should belong_to(:weekday) }
  it { should respond_to(:day_of_week) }
end