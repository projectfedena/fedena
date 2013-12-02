# Fedena LTS: Open source school management system

[![Build Status](https://travis-ci.org/joneslee85/fedena_lts.png?branch=master)](https://travis-ci.org/joneslee85/fedena_lts)
[![Code Climate](https://codeclimate.com/github/joneslee85/fedena_lts.png)](https://codeclimate.com/github/joneslee85/fedena_lts)

Project Fedena is the open source school management system based on Ruby on Rails. It is developed by a team of developers at Foradian Technologies.
The project was made open source by Foradian, and is now maintained by the open source community. Fedena is the ideal solution for schools and campuses that want an easy means to manage all campus records.

The Project Fedena website http://www.projectfedena.org/ is the home to the developer community behind Fedena project.

# What is Fedena LTS edition?

Fedena LTS is a fork of the fedena project, that provides:

* Security fixes for Rails 2.3.x branch
* Bundler support
* TravisCI support
* More test coverage
* Refactor and cleanup codebase
* Extended support for other DBs such as PostgreSQL
* Support Ruby 1.9.x
* Cease support for Ruby 1.8.x

The main reasons behind the decision to fork are:

* Main project repository is stagnated - no development nor patches since the early of 2013
* Lack of effective communication with fedena team
* Lack of test coverages, which makes fedena prone to regressions for modification and updation

# Is Fedora LTS free?

Yes, it is. All fixes will be available to commercial support customers first. We'll release these
patches for public after 3 months. We hope for your understanding as we try to cover the costs
to support this legacy product.

# Commercial Support

There are many customers who are planning to move away from fedena platform due to lack of update from the official project. Yet some could
not afford other alternative solutions due to costs and other reasons. For this very reason, we'd like to announce commercial support plan for Fedena/Fedena Pro.

With the commercial support plan, you would get:

* Latest security patches and fixes to current Fedena 2.3 codebase
* Customer Email support (with 24 hours latest reply)
* Customer Chat support
* More test coverages for fedena codebase, increase production quality and Rails 4 upgrade ready (see Project Athena)
* 3 days development fixes

For more information, please contact our support at: trung.le@ruby-journal.com

# Project Athena (Rails 4 port)

Your investment to Fedena is very important to your business. We understand and believe that you should not throw away your codebase just because
fedena becomes stagnated and obsolete with old Rails technology. We are in progress porting fedena to Rails 4 under Project Athena. By subscribing
to our commercial support plan, you will automatically receive portage updates.

What would you expect with this port?

* Rails 4 support
* Ruby 1.9.x and 2.0.0 support
* Support PostgresSQL, MySQL
* ~60% performance increase
* Cloud Deployment - Heroku, EngineYard, OpenShift
* New plugin engine infrastructure
* Extensive customer product support for upgrade from Fedena 2.3
* Responsive CSS - support mobile, tablet and desktop

# Demo
A demo website for Fedena has been set up at demo.projectfedena.org. You can log in with following usernames and passwords:

    * As admin -- username - admin, password - admin123
    * As student -- username - 1, password - 1123
    * As employee -- username - E1, password - E1123

On localhost, after running ```rake db:seed```, you can login as admin with:

    * username - Admin, password - password

# License

Fedena LTS is released under the Apache License 2.0.
Fedena is released under the Apache License 2.0.

# Installation

RubyGems has deprecated `Gem::SourceIndex#search` after 2011-11-01. Thus Slimgems should be installed instead to maintain compatability until the port to Rails 4 is finished.

```
gem install slimgems
```

Bootstraping with:

```
bundle install
bundle exec rake db:create db:migrate
bundle exec rake db:seed
./scipt/server
```

# Test

```
RAILS_ENV=test bundle exec rake db:create db:migrate
bundle exec rake spec
```

to run individual test, do:

```
./script/spec spec/models/abc_spec.rb
```

