require "spec_helper"
require 'has_and_belongs_to_many_with_deferred_save'

describe "has_and_belongs_to_many_with_deferred_save" do
  describe "room maximum_occupancy" do
    before :all do
      @people = []
      @people << Person.create(:name => 'Filbert')
      @people << Person.create(:name => 'Miguel')
      @people << Person.create(:name => 'Rainer')
      @room = Room.new(:maximum_occupancy => 2)
    end
    after :all do
      Person.delete_all
      Room.delete_all
    end

    it "passes initial checks" do
      Room  .count.should == 0
      Person.count.should == 3

      @room.people.should == []
      @room.people_without_deferred_save.should == []
      @room.people_without_deferred_save.object_id.should_not ==
        @room.unsaved_people.object_id
    end

    it "after adding people to room, it should not have saved anything to the database" do
      @room.people << @people[0]
      @room.people << @people[1]

      # Still not saved to the association table!
      Room.count_by_sql("select count(*) from people_rooms").should == 0
      @room.people_without_deferred_save.size.               should == 0
    end

    it "but room.people.size should still report the current size of 2" do
      @room.people.size.should == 2        # 2 because this looks at unsaved_people and not at the database
    end

    it "after saving the model, the association should be saved in the join table" do
      @room.save    # Only here is it actually saved to the association table!
      @room.errors.full_messages.should == []
      Room.count_by_sql("select count(*) from people_rooms").should == 2
      @room.people.size.                                     should == 2
      @room.people_without_deferred_save.size.               should == 2
    end

    it "when we try to add a 3rd person, it should add a validation error to the errors object like any other validation error" do
      lambda { @room.people << @people[2] }.should_not raise_error
      @room.people.size.       should == 3

      Room.count_by_sql("select count(*) from people_rooms").should == 2
      @room.valid?
      @room.errors.on(:people).should == "This room has reached its maximum occupancy"
      @room.people.size.       should == 3 # Just like with normal attributes that fail validation... the attribute still contains the invalid data but we refuse to save until it is changed to something that is *valid*.
    end

    it "when we try to save, it should fail, because room.people is still invaild" do
      @room.save.should == false
      Room.count_by_sql("select count(*) from people_rooms").should == 2 # It's still not there, because it didn't pass the validation.
      @room.errors.on(:people).should == "This room has reached its maximum occupancy"
      @room.people.size.       should == 3
      @people.map {|p| p.reload; p.rooms.size}.should == [1, 1, 0]
    end

    it "when we reload, it should go back to only having 2 people in the room" do
      @room.reload
      @room.people.size.                                     should == 2
      @room.people_without_deferred_save.size.               should == 2
      @people.map {|p| p.reload; p.rooms.size}.                        should == [1, 1, 0]
    end

    it "if they try to go around our accessors and use the original accessors, then (and only then) will the exception be raised in before_adding_person..." do
      lambda do
        @room.people_without_deferred_save << @people[2]
      end.should raise_error(RuntimeError)
    end

    it "lets you bypass the validation on Room if we add the association from the other side (person.rooms <<)?" do
      @people[2].rooms << @room
      @people[2].rooms.size.should == 1

      # Adding it from one direction does not add it to the other object's association (@room.people), so the validation passes.
      @room.reload.people.size.should == 2
      @people[2].valid?
      @people[2].errors.full_messages.should == []
      @people[2].save.should == true

      # It is only after reloading that @room.people has this 3rd object, causing it to be invalid, and by then it's too late to do anything about it.
      @room.reload.people.size.should == 3
      @room.valid?.should == false
    end

    it "only if you add the validation to both sides, can you ensure that the size of the association does not exceed some limit" do
      @room.reload.people.size.should == 3
      @room.people.delete(@people[2])
      @room.save.should == true
      @room.reload.people.size.should == 2
      @people[2].reload.rooms.size.should == 0

      class << @people[2]
        def validate
          rooms.each do |room|
            this_room_unsaved = rooms_without_deferred_save.include?(room) ? 0 : 1
            if room.people.size + this_room_unsaved > room.maximum_occupancy
              errors.add :rooms, "This room has reached its maximum occupancy"
            end
          end
        end
      end

      @people[2].rooms << @room
      @people[2].rooms.size.should == 1

      @room.reload.people.size.should == 2
      @people[2].valid?
      @people[2].errors.on(:rooms).should == "This room has reached its maximum occupancy"
      @room.reload.people.size.should == 2
    end

    it "still lets you do find" do
      #@room.people2.                     find(:first, :conditions => {:name => 'Filbert'}).should == @people[0]
      #@room.people_without_deferred_save.find(:first, :conditions => {:name => 'Filbert'}).should == @people[0]
      #@room.people2.first(:conditions                      => {:name => 'Filbert'}).should == @people[0]
      #@room.people_without_deferred_save.first(:conditions => {:name => 'Filbert'}).should == @people[0]
      #@room.people_without_deferred_save.find_by_name('Filbert').should == @people[0]

      @room.people.find(:first, :conditions => {:name => 'Filbert'}).should == @people[0]
      @room.people.first(:conditions => {:name => 'Filbert'}).       should == @people[0]
      @room.people.last(:conditions => {:name => 'Filbert'}).        should == @people[0]
      @room.people.find_by_name('Filbert').                          should == @people[0]
    end
  end

  describe "doors" do
    before :all do
      @rooms = []
      @rooms << Room.create(:name => 'Kitchen',     :maximum_occupancy => 1)
      @rooms << Room.create(:name => 'Dining room', :maximum_occupancy => 10)
      @door =   Door.new(:name => 'Kitchen-Dining-room door')
    end

    it "passes initial checks" do
      Room.count.should == 2
      Door.count.should == 0

      @door.rooms.should == []
      @door.rooms_without_deferred_save.should == []
    end

    it "the association has an include? method" do
      @door.rooms << @rooms[0]
      @door.rooms.include?(@rooms[0]).should be_true
      @door.rooms.include?(@rooms[1]).should be_false
    end
  end

end
