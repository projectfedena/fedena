require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class EmployeeCategoryTest < ActiveSupport::TestCase

 should_have_many :employees
 should_have_many :employee_positions
 should_have_named_scope :active, :conditions => {:status => true }


  context 'a new department' do
    setup { @category = Factory.build(:employee_category) }

    should 'be new record' do
      assert @category.new_record?
    end

    should 'be valid' do
      assert @category.valid?
    end

    should 'validate presence of name' do
      @category.name = nil
      assert_invalid @category
      assert @category.errors.invalid?(:name)
    end

    should 'validate presence of prefix' do
      @category.prefix = nil
      assert_invalid @category
      assert @category.errors.invalid?(:prefix)
    end

    should 'not create a category with same prefix' do
      @department = Factory.create(:general_emp_category)
      @department2 = Factory.build(:general_emp_category)
      assert_invalid @department2
      assert @department2.errors.invalid?(:prefix)
    end

    should 'not create a category with same name' do
      @department = Factory.create(:general_emp_category)
      @department2 = Factory.build(:general_emp_category)
      assert_invalid @department2
      assert @department2.errors.invalid?(:name)
    end



  end
end
