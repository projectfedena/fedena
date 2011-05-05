class FinanceFeeStructureElement < ActiveRecord::Base

  #  t.decimal    :amount, :precision => 8, :scale => 2
  #  t.string     :label
  #  t.references :batch
  #  t.references :student_category
  #  t.references :student
  #  t.references :finance_fee
  #  t.references :parent
  #  t.references :fee_collection
  
  belongs_to :batch
  belongs_to :student_category
  belongs_to :student
  belongs_to :finance_fee
  belongs_to :parent, :class_name => 'FinanceFeeStructureElement'
  belongs_to :fee_collection, :class_name => 'FinanceFeeCollection'
  has_one    :descendant, :class_name => 'FinanceFeeStructureElement', :foreign_key => 'parent_id'

  def has_descendant_for_student?(student)
    FinanceFeeStructureElement.exists?(:parent_id => id, :student_id => student.id, :deleted => false)
  end

  class << self

    def get_all_fee_components
      elements = {}
      elements[:all] = find(:all,
        :conditions => {
          :batch_id => nil,
          :student_category_id => nil,
          :student_id => nil,
          :deleted => false
        })
      elements[:by_batch] = find(:all,
        :conditions => "
        batch_id IS NOT NULL AND
        student_id IS NULL AND
        student_category_id IS NULL AND
        deleted = false
        ")
      elements[:by_category] = find(:all, :conditions => "
        student_category_id IS NOT NULL AND
        batch_id IS NULL
        ")
      elements[:by_batch_and_category] = find(:all, :conditions => "
        batch_id IS NOT NULL AND
        student_category_id IS NOT NULL
        ")
      elements
    end

    def get_student_fee_components(student,date)
      elements = {}
      elements[:all] = find(:all,
        :conditions => "
        batch_id IS NULL AND
        student_category_id IS NULL AND
        student_id IS NULL AND
        deleted = false"
      )
      elements[:by_batch] = find(:all,
        :conditions => "
        batch_id = #{student.batch_id} AND
        student_category_id IS NULL AND
        fee_collection_id = NULL AND
        student_id IS NULL AND
        deleted = false
        ")
      elements[:by_batch_and_fee_collection] = find(:all,
        :conditions => "
   
        student_category_id IS NULL AND
        fee_collection_id = #{date}  AND
        student_id IS NULL AND
        deleted = false
        ")
      elements[:by_category] = find(:all, :conditions => "
        batch_id IS NULL AND
        student_category_id = #{student.student_category_id} AND
        student_id IS NULL AND
        deleted = false
        ")
      elements[:by_batch_and_category] = find(:all, :conditions => "
        batch_id = #{student.batch_id} AND
        student_category_id = #{student.student_category_id} AND
        student_id IS NULL AND
        deleted = false
        ")
      elements[:student] = find(:all, :conditions => "
        batch_id IS NULL AND
        student_category_id IS NULL AND
        student_id = #{student.id} AND
        parent_id IS NULL AND
        deleted = false
        ")
      elements[:student_current_fee_cycle] = find(:all, :conditions => "
        student_id = #{student.id} AND
        fee_collection_id = #{date} AND
        parent_id IS NOT NULL AND
        deleted = false
        ")
      elements
    end

    def get_batch_fee_components(batch)
      elements = {}
      elements[:all] = find(:all,
        :conditions => "
        batch_id IS NULL AND
        student_category_id IS NULL AND
        student_id IS NULL AND
        deleted = false"
      )
      elements[:by_batch] = find(:all,
        :conditions => "
        batch_id = #{batch.id} AND
        student_category_id IS NULL AND
        student_id IS NULL AND
        deleted = false
        ")
      elements[:by_category] = find(:all, :conditions => "
        student_category_id IS NOT NULL AND
        batch_id IS NULL
        ")
      elements[:by_batch_and_category] = find(:all, :conditions => "
        batch_id  = #{batch.id} AND
        student_category_id IS NOT NULL
        ")
      elements
 
      elements
    
    end

  end


end
