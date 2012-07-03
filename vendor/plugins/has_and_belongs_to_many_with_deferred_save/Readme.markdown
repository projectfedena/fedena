Make ActiveRecord defer/postpone saving the records you add to an habtm (has_and_belongs_to_many) association until you call model.save, allowing validation in the style of normal attributes.

How to install
==============

As Rails plugin:
    ./script/plugin install git://github.com/TylerRick/has_and_belongs_to_many_with_deferred_save.git

As a gem:
    sudo gem install has_and_belongs_to_many_with_deferred_save

Usage
=====

    class Room < ActiveRecord::Base
      has_and_belongs_to_many_with_deferred_save :people
    end

Motivation
==========

Let's say you want to validate the room.people collection and prevent the user from adding more people to the room than will fit. If they do try to add more people than will fit, you want to display a nice error message on the page and let them try again...

This isn't possible using the standard has_and_belongs_to_many due to these two problems:

1. When we do the assignment to our collection (room.people = whatever), it immediately saves it in our join table (people_rooms) rather than waiting until we call room.save.

2. You can "validate" using habtm's :before_add option ... but it any errors added there end up being ignored/lost. The only way to abort the save from a before_add seems to be to raise an exception... 

But we don't want to raise an exception when the user violates our validation; we want validation of the people collection to be handled the same as any other field in the Room model: we want it to simply add an error to the Room model's error array which we can than display on the form with the other input errors.

has_and_belongs_to_many_with_deferred_save solves this problem by overriding the setter method for your collection (people=), causing it to store the new members in a temporary variable (unsaved_people) rather than saving it immediately.

You can then validate the unsaved collection as you would any other attribute, adding to self.errors if something is invalid about the collection (too many members, etc.).

The unsaved collection is automatically saved when you call save on the model.


Compatibility
=============

Tested with Rails 2.3.4.

Bugs
====

http://github.com/TylerRick/has_and_belongs_to_many_with_deferred_save/issues

History
=======

It started as a [post](http://www.ruby-forum.com/topic/81095) to the Rails mailing list asking how to validate a has_and_belongs_to_many collection/association.

License
=======

This plugin is licensed under the BSD license.

2010 (c) Contributors
2007 (c) QualitySmith, Inc.
