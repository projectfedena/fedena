require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class EmployeeDepartmentTest < ActiveSupport::TestCase
  
 should_have_many :employees
 should_have_named_scope :active, :conditions => {:status => true }
 

  context 'a new department' do
    setup { @department = Factory.build(:employee_department) }

    should 'be new record' do
      assert @department.new_record?
    end

    should 'be valid' do
      assert @department.valid?
    end

    should 'validate presence of name' do
      @department.name = nil
      assert_invalid @department
      assert @department.errors.invalid?(:name)
    end

    should 'not create a department with same code' do
      @department = Factory.create(:general_department)
      @department2 = Factory.build(:general_department)
      assert_invalid @department2
      assert @department2.errors.invalid?(:code)
    end

    should 'not create a department with same name' do
      @department = Factory.create(:general_department)
      @department2 = Factory.build(:general_department)
      assert_invalid @department2
      assert @department2.errors.invalid?(:name)
    end



  end
end
