require 'spec_helper'

describe TimetablesHelper do
  describe '#subject_code' do
    let(:tte) do
      subject   = FactoryGirl.create(:subject, :code => 'RED')
      timetable = FactoryGirl.create(:timetable)
      @tte = FactoryGirl.create(:timetable_entry, :subject => subject, :timetable => timetable)
    end

    it 'returns subject code' do
      helper.subject_code(tte).should == "RED\n"
    end
  end

  describe '#subject_name' do
    let(:tte) do
      subject   = FactoryGirl.create(:subject, :name => 'BLU')
      timetable = FactoryGirl.create(:timetable)
      FactoryGirl.create(:timetable_entry, :subject => subject, :timetable => timetable)
    end

    it 'returns subject name' do
      helper.subject_name(tte).should == "BLU\n"
    end
  end

  describe '#elective_subject_code' do
    context 'elective_group is present' do
      before do
        @elective_group = FactoryGirl.create(:elective_group)
        @subject   = FactoryGirl.create(:subject, :code => 'RED', :elective_group => @elective_group)
        @employee  = FactoryGirl.create(:employee)
        @employee_subject = FactoryGirl.create(:employees_subject, :employee => @employee, :subject => @subject)
        @timetable = FactoryGirl.create(:timetable)
        @tte = FactoryGirl.create(:timetable_entry, :subject => @subject, :timetable => @timetable)
      end

      it 'returns elective subject code' do
        helper.elective_subject_code(@tte, @employee).should == "RED\n"
      end
    end

    context 'elective_group is blank' do
      let(:employee) { FactoryGirl.create(:employee) }
      let(:tte) do
        subject   = FactoryGirl.create(:subject, :code => 'RED')
        timetable = FactoryGirl.create(:timetable)
        @tte = FactoryGirl.create(:timetable_entry, :subject => subject, :timetable => timetable)
      end

      it 'returns subject code' do
        helper.elective_subject_code(tte, employee).should == "RED\n"
      end
    end
  end

  describe '#timetable_batch' do
    let(:tte) do
      course = FactoryGirl.create(:course, :code => 'CODE')
      batch  = FactoryGirl.create(:batch, :name => 'RED', :course => course)
      FactoryGirl.create(:timetable_entry, :batch => batch)
    end

    it 'returns batch full_name' do
      helper.timetable_batch(tte).should == "CODE - RED"
    end
  end

  describe '#employee_name' do
    let(:tte) do
      employee = FactoryGirl.create(:employee, :first_name => 'Trung')
      FactoryGirl.create(:timetable_entry, :employee => employee)
    end

    it 'returns employee first name' do
      helper.employee_name(tte).should == 'Trung'
    end
  end

  describe '#employee_full_name' do
    let(:tte) do
      employee = FactoryGirl.create(:employee,
        :first_name  => 'Trung',
        :middle_name => 'Duc',
        :last_name   => 'Le')
      FactoryGirl.create(:timetable_entry, :employee => employee)
    end

    it 'returns employee full name' do
      helper.employee_full_name(tte).should == 'Trung Duc Le'
    end
  end
end