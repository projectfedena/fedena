# To do: make it work to call this twice in a class. Currently that probably wouldn't work, because it would try to alias methods to existing names...
# Note: before_save must be defined *before* including this module, not after.

module ActiveRecord
  module Associations
    module ClassMethods
      # Instructions:
      #
      # Replace your existing call to has_and_belongs_to_many with has_and_belongs_to_many_with_deferred_save.
      #
      # Then add a validation method that adds an error if there is something wrong with the (unsaved) collection. This will prevent it from being saved if there are any errors.
      #
      # Example:
      #
      #  def validate
      #    if people.size > maximum_occupancy
      #      errors.add :people, "There are too many people in this room"
      #    end
      #  end
      def has_and_belongs_to_many_with_deferred_save(*args)
        has_and_belongs_to_many *args
        collection_name = args[0].to_s
        collection_singular_ids = collection_name.singularize + "_ids"

        # this will delete all the assocation into the join table after obj.destroy
        after_destroy { |record| record.save }

        attr_accessor :"unsaved_#{collection_name}"
        attr_accessor :"use_original_collection_reader_behavior_for_#{collection_name}"

        define_method "#{collection_name}_with_deferred_save=" do |collection|
          #puts "has_and_belongs_to_many_with_deferred_save: #{collection_name} = #{collection.collect(&:id).join(',')}"
          self.send "unsaved_#{collection_name}=", collection
        end

        define_method "#{collection_name}_with_deferred_save" do |*args|
          if self.send("use_original_collection_reader_behavior_for_#{collection_name}")
            self.send("#{collection_name}_without_deferred_save")
          else
            if self.send("unsaved_#{collection_name}").nil?
              send("initialize_unsaved_#{collection_name}", *args)
            end
            self.send("unsaved_#{collection_name}")
          end
        end

        alias_method_chain :"#{collection_name}=", 'deferred_save'
        alias_method_chain :"#{collection_name}", 'deferred_save'

        define_method "#{collection_singular_ids}_with_deferred_save" do |*args|
          if self.send("use_original_collection_reader_behavior_for_#{collection_name}")
            self.send("#{collection_singular_ids}_without_deferred_save")
          else
            if self.send("unsaved_#{collection_name}").nil?
              send("initialize_unsaved_#{collection_name}", *args)
            end
            self.send("unsaved_#{collection_name}").map { |e| e[:id] }
          end
        end

        alias_method_chain :"#{collection_singular_ids}", 'deferred_save'


        define_method "before_save_with_deferred_save_for_#{collection_name}" do
          # Question: Why do we need this @use_original_collection_reader_behavior stuff?
          # Answer: Because AssociationCollection#replace(other_array) performs a diff between current_array and other_array and deletes/adds only
          # records that have changed.
          # In order to perform that diff, it needs to figure out what "current_array" is, so it calls our collection_with_deferred_save, not
          # knowing that we've changed its behavior. It expects that method to return the elements of that collection that are in the *database*
          # (the original behavior), so we have to provide that behavior...  If we didn't provide it, it would end up trying to take the diff of
          # two identical collections so nothing would ever get saved.
          # But we only want the old behavior in this case -- most of the time we want the *new* behavior -- so we use
          # @use_original_collection_reader_behavior as a switch.

          if self.respond_to? :"before_save_without_deferred_save_for_#{collection_name}"
            self.send("before_save_without_deferred_save_for_#{collection_name}")
          end

          self.send "use_original_collection_reader_behavior_for_#{collection_name}=", true
          if self.send("unsaved_#{collection_name}").nil?
            send("initialize_unsaved_#{collection_name}", *args)
          end
          self.send "#{collection_name}_without_deferred_save=", self.send("unsaved_#{collection_name}")
            # /\ This is where the actual save occurs.
          self.send "use_original_collection_reader_behavior_for_#{collection_name}=", false

          true
        end
        alias_method_chain :"before_save", "deferred_save_for_#{collection_name}"


        define_method "reload_with_deferred_save_for_#{collection_name}" do
          # Reload from the *database*, discarding any unsaved changes.
          returning self.send("reload_without_deferred_save_for_#{collection_name}") do
            self.send "unsaved_#{collection_name}=", nil
              # /\ If we didn't do this, then when we called reload, it would still have the same (possibly invalid) value of
              # unsaved_collection that it had before the reload.
          end
        end
        alias_method_chain :"reload", "deferred_save_for_#{collection_name}"


        define_method "initialize_unsaved_#{collection_name}" do |*args|
          #puts "Initialized to #{self.send("#{collection_name}_without_deferred_save").clone.inspect}"
          self.send "unsaved_#{collection_name}=", self.send("#{collection_name}_without_deferred_save", *args).clone
            # /\ We initialize it to collection_without_deferred_save in case they just loaded the object from the
            # database, in which case we want unsaved_collection to start out with the "saved collection".
            # If they just constructed a *new* object, this will still work, because self.collection_without_deferred_save.clone
            # will return a new HasAndBelongsToManyAssociation (which acts like an empty array, []).
            # Important: If we don't use clone, then it does an assignment by reference and any changes to unsaved_collection
            # will also change *collection_without_deferred_save*! (Not what we want! Would result in us saving things
            # immediately, which is exactly what we're trying to avoid.)

          # trick collection_name.include?(obj)
          # If you use a collection of SignelTableInheritance and didn't :select 'type' the
          # include? method will not find any subclassed object.
          class << eval("@unsaved_#{collection_name}")
            def include_with_deferred_save?(obj)
              if self.detect { |itm| itm == obj || (itm[:id] == obj[:id] && obj.is_a?(itm.class) ) }
                return true
              else
                return false
              end
            end
            alias_method_chain :include?, 'deferred_save'
          end


          collection_without_deferred_save =  self.send("#{collection_name}_without_deferred_save")
          # (We don't have access to locals inside a normal class << object block, so we have to do it this way instead.)
          (class << eval("@unsaved_#{collection_name}"); self end).class_eval do
            define_method :find do |*args|
              collection_without_deferred_save.send(:find, *args)
            end
            # We have to override these so that it doesn't call Array's version of these methods.
            # Otherwise user will get a "can't convert Hash into Integer" error
            define_method :first do |*args|
              collection_without_deferred_save.send(:first, *args)
            end
            define_method :last do |*args|
              collection_without_deferred_save.send(:first, *args)
            end

            define_method :method_missing do |method, *args|
              #puts "#{self.class}.method_missing(#{method}) (#{collection_without_deferred_save.inspect})"
              collection_without_deferred_save.send(method, *args)
            end
          end

        end
        private :"initialize_unsaved_#{collection_name}"

      end
    end
  end
end
