require 'spec_helper'

describe ArchivedEmployeeBankDetail do
  it { should belong_to(:archived_employee) }
  it { should belong_to(:bank_field) }
end