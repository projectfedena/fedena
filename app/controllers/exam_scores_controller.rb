class ExamScoresController < ApplicationController
  in_place_edit_for :exam_score, :score
  before_filter :protect_other_student_data
end