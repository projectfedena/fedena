require 'spec_helper'

describe SmsSetting do
  describe '#application_sms_active' do
    context 'ApplicationEnabled setting is found' do
      let(:application_sms) { SmsSetting.create(:settings_key => 'ApplicationEnabled', :is_enabled => true) }

      it 'returns true' do
        application_sms.application_sms_active.should be_true
      end
    end

    context 'ApplicationEnabled setting is not found' do
      let(:application_sms) { SmsSetting.create(:settings_key => 'ApplicationEnabled', :is_enabled => false) }

      it 'returns false' do
        application_sms.application_sms_active.should be_false
      end
    end
  end

  describe '#student_sms_active' do
    context 'StudentSmsEnabled setting is found' do
      let(:student_sms) { SmsSetting.create(:settings_key => 'StudentSmsEnabled', :is_enabled => true) }

      it 'returns true' do
        student_sms.student_sms_active.should be_true
      end
    end

    context 'StudentSmsEnabled setting is not found' do
      let(:student_sms) { SmsSetting.create(:settings_key => 'StudentSmsEnabled', :is_enabled => false) }

      it 'returns false' do
        student_sms.student_sms_active.should be_false
      end
    end
  end

  describe '#student_admission_sms_active' do
    context 'StudentAdmissionEnabled setting is found' do
      let(:student_adm_sms) { SmsSetting.create(:settings_key => 'StudentAdmissionEnabled', :is_enabled => true) }

      it 'returns true' do
        student_adm_sms.student_admission_sms_active.should be_true
      end
    end

    context 'StudentAdmissionEnabled setting is not found' do
      let(:student_adm_sms) { SmsSetting.create(:settings_key => 'StudentAdmissionEnabled', :is_enabled => false) }

      it 'returns false' do
        student_adm_sms.student_admission_sms_active.should be_false
      end
    end
  end

  describe '#parent_sms_active' do
    context 'ParentSmsEnabled setting is found' do
      let(:parent_sms) { SmsSetting.create(:settings_key => 'ParentSmsEnabled', :is_enabled => true) }

      it 'returns true' do
        parent_sms.parent_sms_active.should be_true
      end
    end

    context 'ParentSmsEnabled setting is not found' do
      let(:parent_sms) { SmsSetting.create(:settings_key => 'ParentSmsEnabled', :is_enabled => false) }

      it 'returns false' do
        parent_sms.parent_sms_active.should be_false
      end
    end
  end

  describe '#employee_sms_active' do
    context 'EmployeeSmsEnabled setting is found' do
      let(:employee_sms) { SmsSetting.create(:settings_key => 'EmployeeSmsEnabled', :is_enabled => true) }

      it 'returns true' do
        employee_sms.employee_sms_active.should be_true
      end
    end

    context 'EmployeeSmsEnabled setting is not found' do
      let(:employee_sms) { SmsSetting.create(:settings_key => 'EmployeeSmsEnabled', :is_enabled => false) }

      it 'returns false' do
        employee_sms.employee_sms_active.should be_false
      end
    end
  end

  describe '#attendance_sms_active' do
    context 'AttendanceEnabled setting is found' do
      let(:attendance_sms) { SmsSetting.create(:settings_key => 'AttendanceEnabled', :is_enabled => true) }

      it 'returns true' do
        attendance_sms.attendance_sms_active.should be_true
      end
    end

    context 'AttendanceEnabled setting is not found' do
      let(:attendance_sms) { SmsSetting.create(:settings_key => 'AttendanceEnabled', :is_enabled => false) }

      it 'returns false' do
        attendance_sms.attendance_sms_active.should be_false
      end
    end
  end

  describe '#event_news_sms_active' do
    context 'NewsEventsEnabled setting is found' do
      let(:event_news_sms) { SmsSetting.create(:settings_key => 'NewsEventsEnabled', :is_enabled => true) }

      it 'returns true' do
        event_news_sms.event_news_sms_active.should be_true
      end
    end

    context 'NewsEventsEnabled setting is not found' do
      let(:event_news_sms)  { SmsSetting.create(:settings_key => 'NewsEventsEnabled', :is_enabled => false) }

      it 'returns false' do
        event_news_sms.event_news_sms_active.should be_false
      end
    end
  end

  describe '#exam_result_schedule_sms_active' do
    context 'ExamScheduleResultEnabled setting is found' do
      let(:exam_result_schedule_sms) { SmsSetting.create(:settings_key => 'ExamScheduleResultEnabled', :is_enabled => true) }

      it 'returns true' do
        exam_result_schedule_sms.exam_result_schedule_sms_active.should be_true
      end
    end

    context 'ExamScheduleResultEnabled setting is not found' do
      let(:exam_result_schedule_sms) { SmsSetting.create(:settings_key => 'ExamScheduleResultEnabled', :is_enabled => false) }

      it 'returns false' do
        exam_result_schedule_sms.exam_result_schedule_sms_active.should be_false
      end
    end
  end

  describe '.get_sms_config' do
    before do
      if File.exists?("#{Rails.root}/config/sms_settings.yml")
        @config = YAML.load_file(File.join(Rails.root,"config","sms_settings.yml"))
      end
    end

    it 'returns config' do
      SmsSetting.get_sms_config.should == @config
    end
  end

  describe '.application_sms_status' do
    context 'ApplicationEnabled setting is found' do
      before { @application_sms = SmsSetting.create(:settings_key => 'ApplicationEnabled', :is_enabled => true) }

      it 'returns true' do
        SmsSetting.application_sms_status.should be_true
      end
    end

    context 'ApplicationEnabled setting is not found' do
      before { @application_sms = SmsSetting.create(:settings_key => 'ApplicationEnabled', :is_enabled => false) }

      it 'returns false' do
        SmsSetting.application_sms_status.should be_false
      end
    end
  end
end