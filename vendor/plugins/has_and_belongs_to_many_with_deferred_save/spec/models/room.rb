class Room < ActiveRecord::Base
  has_and_belongs_to_many_with_deferred_save :people, :before_add => :before_adding_person
  has_and_belongs_to_many :people2, :class_name => 'Person'
  has_and_belongs_to_many_with_deferred_save :doors

  def validate
    if people.size > maximum_occupancy
      errors.add :people, "This room has reached its maximum occupancy"
    end
  end

  # Just in case they try to bypass our new accessor and call people_without_deferred_save directly...
  # (This should never be necessary; it is for demonstration purposes only...)
  def before_adding_person(person)
    if self.people_without_deferred_save.size + [person].size > maximum_occupancy
      raise "There are too many people in this room"
    end
  end
end
