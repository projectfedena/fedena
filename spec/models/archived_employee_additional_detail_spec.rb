require 'spec_helper'

describe ArchivedEmployeeAdditionalDetail do
  it { should belong_to(:archived_employee) }
  it { should belong_to(:additional_field) }
end