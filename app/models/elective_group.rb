class ElectiveGroup < ActiveRecord::Base
  belongs_to :batch
  has_many :subjects

  validates_presence_of :name

  named_scope :for_batch, lambda { |b| { :conditions => { :batch_id => b, :is_deleted => false } } }

  def inactivate
    update_attribute(:is_deleted, true)
  end
end
