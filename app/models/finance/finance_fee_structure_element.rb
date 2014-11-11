# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
class FinanceFeeStructureElement < ActiveRecord::Base

  #  t.decimal    :amount, :precision => 8, :scale => 2
  #  t.string     :label
  #  t.references :batch
  #  t.references :student_category
  #  t.references :student
  #  t.references :parent
  #  t.references :fee_collection

  belongs_to :batch
  belongs_to :student_category
  belongs_to :student
  belongs_to :parent, :class_name => 'FinanceFeeStructureElement'
  belongs_to :fee_collection, :class_name => 'FinanceFeeCollection'
  has_one    :descendant, :class_name => 'FinanceFeeStructureElement', :foreign_key => 'parent_id'

  def has_descendant_for_student?(student)
    FinanceFeeStructureElement.exists?(:parent_id => id,
                                       :student_id => student.id,
                                       :deleted => false)
  end

  class << self

    def all_fee_components
      all(:conditions => {:batch_id => nil,
                          :student_category_id => nil,
                          :student_id => nil,
                          :deleted => false})
    end

    def all_fee_components_by_batch
      all(:conditions => "batch_id IS NOT NULL AND
                          student_id IS NULL AND
                          student_category_id IS NULL AND
                          deleted = false")
    end

    def all_fee_components_by_category
      all(:conditions => "student_category_id IS NOT NULL AND
                          batch_id IS NULL")
    end

    def all_fee_components_by_batch_and_category
      all(:conditions => "batch_id IS NOT NULL AND
                          student_category_id IS NOT NULL")
    end

    def fee_components_by_batch_and_category(batch_id, student_category_id)
      all(:conditions => { batch_id: batch_id,
                           student_category_id: student_category_id,
                           student_id: nil,
                           deleted: false })
    end

    def student_fee_components_by_batch(batch_id)
      all(:conditions => { batch_id: batch_id,
                           student_category_id: nil,
                           fee_collection_id: nil,
                           student_id: nil,
                           deleted: false })
    end

    def student_fee_components_by_collection(date)
      all(:conditions => { student_category_id: nil,
                           fee_collection_id: date,
                           student_id: nil,
                           deleted: false })
    end

    def student_fee_components_by_student(student_id)
      all(:conditions => { batch_id: nil,
                           student_category_id: nil,
                           student_id: student_id,
                           parent_id: nil,
                           deleted: false })
    end

    def student_current_fee_cycle(student_id, date)
      all(:conditions => ["student_id = ? AND
                           fee_collection_id = ? AND
                           parent_id IS NOT NULL AND
                           deleted = false", student_id, date])
    end

    def batch_fee_component_by_batch(batch_id)
      all(:conditions => ["batch_id = ? AND
                           student_category_id IS NOT NULL", batch_id])
    end

    def get_all_fee_components
      elements = {}
      elements[:all] = all_fee_components
      elements[:by_batch] = all_fee_components_by_batch
      elements[:by_category] = all_fee_components_by_category
      elements[:by_batch_and_category] = all_fee_components_by_batch_and_category
      elements
    end

    def get_student_fee_components(student, date)
      elements = {}
      elements[:all] = all_fee_components
      elements[:by_batch] = student_fee_components_by_batch(student.batch_id)
      elements[:by_batch_and_fee_collection] = student_fee_components_by_collection(date)
      elements[:by_category] = fee_components_by_batch_and_category(nil, student.student_category_id)
      elements[:by_batch_and_category] = fee_components_by_batch_and_category(student.batch_id,
                                                                              student.student_category_id)
      elements[:student] = student_fee_components_by_student(student.id)
      elements[:student_current_fee_cycle] = student_current_fee_cycle(student.id, date)
      elements
    end

    def get_batch_fee_components(batch)
      elements = {}
      elements[:all] = all_fee_components
      elements[:by_batch] = fee_components_by_batch_and_category(batch.id, nil)
      elements[:by_category] = all_fee_components_by_category
      elements[:by_batch_and_category] = batch_fee_component_by_batch(batch.id)
      elements
    end
  end
end
