class AddGpaCwaIndices < ActiveRecord::Migration
  def self.up
	add_index :grouped_exams,[:batch_id,:exam_group_id]
	add_index :previous_exam_scores,[:student_id,:exam_id]
  end

  def self.down
	remove_index :grouped_exams,[:batch_id,:exam_group_id]
	remove_index :previous_exam_scores,[:student_id,:exam_id]
  end
end
