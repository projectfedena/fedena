require 'test_helper'

class ElectiveGroupTest < ActiveSupport::TestCase
  should_belong_to :batch
  should_have_many :subjects

  should_validate_presence_of :name,:batch_id

  should_have_named_scope :for_batch

  context "existing elective group" do

    setup do
      @elective_group = Factory.build(:elective_group)
    end

    should 'be new a active new record' do
      assert !@elective_group.is_deleted
      assert @elective_group.new_record?
    end


    should ' be disabled' do
      @elective_group.inactivate
      assert @elective_group.is_deleted
    end


  end

end
