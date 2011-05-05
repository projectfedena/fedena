# Group
class Group < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :title, :members, :description

  serialize :members
  
  before_validation :build_empty_members, :if => :empty_members?
  
  protected
  def empty_members?
    self.members.blank?
  end
  
  def build_empty_members
    self.members = []
  end

end
