class AddIndexToFedenaGpaAndCwa < ActiveRecord::Migration
  def self.up
	add_index :grouped_batches,[:batch_group_id]
	add_index :grouped_exam_reports,[:batch_id,:student_id,:score_type],:name => 'by_batch_student_and_score_type'
  end

  def self.down
	remove_index :grouped_batches,[:batch_group_id]
	remove_index :grouped_exam_reports,[:batch_id,:student_id,:score_type],:name => 'by_batch_student_and_score_type'
  end
end
