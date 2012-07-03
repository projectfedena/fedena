class BatchGroup < ActiveRecord::Base
  belongs_to :course
  has_many :grouped_batches, :dependent=>:destroy
  has_many :batches, :through=>:grouped_batches

  validates_presence_of :name, :course_id

  def has_active_batches
    self.batches.each do|b|
      return true if (b.is_active and !b.is_deleted)
    end
    return false
  end

end
