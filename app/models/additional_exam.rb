#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class AdditionalExam < ActiveRecord::Base
  validates_presence_of :start_time
  validates_presence_of :end_time

  belongs_to :additional_exam_group
  belongs_to :subject

  has_one :event, :as => :origin
  has_many :additional_exam_scores
  before_destroy :removable?

  accepts_nested_attributes_for :additional_exam_scores

  def removable?
    self.additional_exam_scores.reject{|es| es.marks.nil? and es.grading_level_id.nil?}.empty?
  end

  def validate
    errors.add_to_base("#{t('minmarks_cant_be_more_than_maxmarks')}") \
      if minimum_marks and maximum_marks and minimum_marks > maximum_marks
    unless self.start_time.nil? or self.end_time.nil?
      errors.add_to_base("#{t('end_time_cannot_before_start_time')}")if self.end_time < self.start_time
    end
  end

  def before_save
    self.weightage = 0 if self.weightage.nil?
  end

  def after_create
    create_exam_event
  end

  def after_update
    update_exam_event
  end

  def score_for(student_id)
    exam_score = self.additional_exam_scores.find(:first, :conditions => { :student_id => student_id })
    exam_score.nil?? AdditionalExamScore.new : exam_score
  end


  private
  def create_exam_event
    if self.event.blank?
      new_event = Event.create do |e|
        e.title       = "#{t('additional_exams_text')}"
        e.description = "#{self.additional_exam_group.name} #{t('for')} #{self.subject.batch.full_name} , #{t('subject')} : #{self.subject.name}"
        e.start_date  = self.start_time
        e.end_date    = self.end_time
        e.is_exam     = true
        e.origin      = self
      end
      batch_event = BatchEvent.create do |be|
        be.event_id = new_event.id
        be.batch_id = self.additional_exam_group.batch_id
      end
      #self.event_id = new_event.id
      self.update_attributes(:event_id=>new_event.id)
    end
  end

  def update_exam_event
      self.event.update_attributes(:start_date => self.start_time, :end_date => self.end_time) unless self.event.blank?
  end
end
