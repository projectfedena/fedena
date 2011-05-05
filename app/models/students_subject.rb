class StudentsSubject < ActiveRecord::Base
  belongs_to :student
  belongs_to :subject

  def student_assigned(student,subject)
    StudentsSubject.find_by_student_id_and_subject_id(student,subject)
  end
end
