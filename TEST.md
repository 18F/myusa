# How to Setup and Run Tests

MyUSA uses several different tools for testing various aspects of its operation:

* [Rspec](http://rspec.info/), a behavior-driven development testing framework for Ruby
* [Capybara](http://jnicklas.github.io/capybara/), a library for integration testing
* [Code Climate](https://codeclimate.com/), a service for automated code reviews

These testing mechanisms use some additional tools to get what they need done

* [Site Prism](https://github.com/natritmeyer/site_prism), a simple DSL for the [Page-Object Model](http://www.guru99.com/page-object-model-pom-page-factory-in-selenium-ultimate-guide.html) used for Selenium view testing
* [Database Cleaner](https://github.com/DatabaseCleaner/database_cleaner), cleans the test database between tests
* [Poltergeist](https://github.com/teampoltergeist/poltergeist), a [PhantomJS](http://phantomjs.org/) driver for Capybara
* [Factory Girl](https://github.com/thoughtbot/factory_girl_rails), an alternative to fixtures for loading test records
* [Fakeweb](https://github.com/chrisk/fakeweb), a library for mocking/stubbing web requests within tests
* [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers), some additional matchers for Rspec
* [Timecop](https://github.com/travisjeffery/timecop), a utility for testing time-sensitive actions
* [Capybara Email](https://github.com/dockyard/capybara-email), test email actions within Capybara
* [SMS Spec](https://github.com/mhs/sms-spec), a library for testing SMS messages within Rspec and Cucumber

All of these are installed automatically when you run the `bundle install` step within [INSTALL.md](./INSTALL.md), but you will also have to run an additional command to install PhantomJS locally:

```sh
brew install phantomjs
```

## Running the Tests

To run the tests, simply type this at the command line

```sh
bundle exec rake
```

This will run for a while and print out a `.` to the screen for every test that runs successfully. When it is finished, you should see something like this

```
Pending:
  Api::V1 Authorized Scopes API need to figure out how to query for scopes with Doorkeeper
    # No reason given
    # ./spec/requests/v1/api_spec.rb:344
  Api::V1 GET /api/v1/profile when the user queried exists when the schema parameter is set need to understand Schema.org requirement
    # No reason given
    # ./spec/requests/v1/api_spec.rb:107

Finished in 28.09 seconds (files took 4.35 seconds to load)
386 examples, 0 failures, 2 pending
```

There may be several tests that are marked as pending. These are tests that were deactivated for some reason or another and do not necessarily indicate a test failure. There is only a problem if you see a `failures` number that is greater than 0.

