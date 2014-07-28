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

# Project Athena

Your investment to Fedena is very important to your business. We understand and believe that Fedena should not impede the growth of your business. Sadly the clunky and obsolete Fedena makes it hard us for us, developers and you to achieve that goal. Hence, we decided to take a bold decision by starting a new project from scratch. Learning from your valuable feedbacks and combining with the state of the art Lotus Framework, we are ambitious to bring you the best product of the industry.

What would you expect with this new product?

* Lotus Framework based
* 1st class microservice architecture
* Ruby 2.0.0 or newer support
* Support PostgresSQL, MySQL, Redis and MongoDB
* ~300% performance increase
* Cloud Deployment - Heroku, EngineYard, OpenShift
* New plugin engine infrastructure
* Extensive customer product support for upgrade from Fedena 2.3 or Fedena LTS
* Responsive CSS - support mobile, tablet and desktop

Previously, we aimed to rewrite in Rails 4. After 6 months in development, we failed to achieve the objectives due to financial problems and technical shortages. It was a tough time for our company and we apologize to our customers who have been patiently waiting for the good news. In July 2014, we successfully secured a first round funding from a private investor, enough for us to restart the project. This time we'll take a new approach by moving away from Rails 4 and toward Lotus Framework. We truly believe the simplicty yet superiosity over Rails would be the game changer for your business. For more details, please do not hesitate to contact us.

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

RubyGems has deprecated `Gem::SourceIndex#search` after 2011-11-01. Thus Slimgems should be installed instead to maintain compatability.

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

