class AdditionalExam < ActiveRecord::Base
  validates_presence_of :start_time
  validates_presence_of :end_time

  belongs_to :additional_exam_group
  belongs_to :subject

  belongs_to :event
  has_many :additional_exam_scores
  before_destroy :removable?

  accepts_nested_attributes_for :additional_exam_scores

  def removable?
    self.additional_exam_scores.reject{|es| es.marks.nil? and es.grading_level_id.nil?}.empty?
  end

  def validate
    errors.add(:minimum_marks, "can't be more than max marks.") \
      if minimum_marks and maximum_marks and minimum_marks > maximum_marks
    unless self.start_time.nil? or self.end_time.nil?
      errors.add(:end_time, "can not be before the start time")if self.end_time < self.start_time
    end
  end

  def before_save
    self.weightage = 0 if self.weightage.nil?
  end

  def after_save
    update_exam_event
  end

  def score_for(student_id)
    exam_score = self.additional_exam_scores.find(:first, :conditions => { :student_id => student_id })
    exam_score.nil?? AdditionalExamScore.new : exam_score
  end


  private
  def update_exam_event
    if self.event.nil?
      new_event = Event.create do |e|
        e.title       = "Additional Exam"
        e.description = "#{self.additional_exam_group.name} for #{self.subject.batch.full_name} , Subject : #{self.subject.name}"
        e.start_date  = self.start_time
        e.end_date    = self.end_time
        e.is_exam     = true
      end
      batch_event = BatchEvent.create do |be|
        be.event_id = new_event.id
        be.batch_id = self.additional_exam_group.batch_id
      end
      #self.event_id = new_event.id
      self.update_attributes(:event_id=>new_event.id)
    else
      self.event.update_attributes(:start_date => self.start_time, :end_date => self.end_time)
    end
  end
end
