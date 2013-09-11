require 'spec_helper'

describe PeriodEntry do
  it { should belong_to(:batch) }
  it { should belong_to(:class_timing) }
  it { should belong_to(:subject) }
  it { should belong_to(:employee) }
end
