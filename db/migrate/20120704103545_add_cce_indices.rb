class AddCceIndices < ActiveRecord::Migration
  def self.up
    table_indexes = [
      {:cce_grades=>[:cce_grade_set_id]},
      {:fa_criterias=>[:fa_group_id]},
      {:courses=>[:grading_type]},
      {:fa_groups_subjects=>[:subject_id,:fa_group_id]},
      {:observations=>[:observation_group_id]},
      {:cce_weightages_courses=>[:cce_weightage_id,:course_id]},
      {:courses_observation_groups=>[:observation_group_id,:course_id]}
    ]
    table_indexes.each do |table|
      table.values.each do |columns|
        columns.each do |column_name|
          add_index(table.keys.first,column_name)
        end
      end
    end
    add_index(:cce_reports,[:observable_id,:student_id,:batch_id,:exam_id,:observable_type],:name=>:cce_report_join_index)
    add_index(:cce_weightages_courses,[:course_id,:cce_weightage_id],:name=>:index_for_join_table_cce_weightage_courses)
    add_index(:descriptive_indicators,[:describable_id,:describable_type,:sort_order],:name=>:describable_index)
    add_index(:assessment_scores,[:student_id,:batch_id,:descriptive_indicator_id,:exam_id],:name=>:score_index)
    add_index(:fa_groups_subjects,[:fa_group_id,:subject_id],:name=>:score_index)
  end

  def self.down
    table_indexes = [
      {:cce_grades=>[:cce_grade_set_id]},
      {:fa_criterias=>[:fa_group_id]},
      {:courses=>[:grading_type]},
      {:fa_groups_subjects=>[:subject_id,:fa_group_id]},
      {:observations=>[:observation_group_id]},
      {:cce_weightages_courses=>[:cce_weightage_id,:course_id]},
      {:courses_observation_groups=>[:observation_group_id,:course_id]}

    ]
    table_indexes.each do |table|
      table.values.each do |columns|
        columns.each do |column_name|
          remove_index(table.keys.first,column_name)
        end
      end
    end
    remove_index(:cce_reports,:name=>:cce_report_join_index)
    remove_index(:cce_weightages_courses,:name=>:index_for_join_table_cce_weightage_courses)
    remove_index(:descriptive_indicators,:name=>:describable_index)
    remove_index(:assessment_scores,:name=>:score_index)
    remove_index(:fa_groups_subjects,:name=>:score_index)
  end
end
