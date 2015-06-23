# MyUSA Development Guide

This is how you get up and running with the MyUSA codebase.  Enclosed are directions for setting up your development environment and deploying MyUSA.

## Getting up and running

To get your Rails development environment setup, here's the steps to follow.

1. Install Dependencies.  These are the minimum versions supported.
      - Ruby 2.1.1
      - Rails 4.1.0
      - Git 1.9.2
      - MySQL 5.6

    [rbenv](https://github.com/sstephenson/rbenv) is convenient for managing Ruby/Rails versions.

2. Clone the `myusa` project

    In the directory where you want to store your development files, do the following:

    ```sh
    git clone https://github.com/18F/myusa.git
    ```

3. Install Ruby Gems

    Change into the directory (it would be `cd myusa` from wherever you executed the above command) and do the following:

    ```sh
    bundle install
    ```

    Note: MySQL must be previously installed for the mysql gem install to work

4. Create your configuration files

    ```sh
    cp config/environments/development.example.rb config/environments/development.rb
    cp config/database.yml.example config/database.yml
    cp config/secrets.yml.example config/secrets.yml
    rake secret
    ```

    Copy the result of the above rake command to the `RAILS_SECRET_TOKEN` variables in `config/secrets.yml`

5. Create the development and test databases

    Make sure you have MySQL running.  By default, the development environment looks to connect to MySQL using the root MySQL user with no password. Also, make sure MySQL is set to use UTC as the timezone (http://stackoverflow.com/questions/947299/how-do-i-make-mysqls-now-and-curdate-functions-use-utc)

    If you're running on an OS or distribution other than Ubuntu, ensure that the `socket` setting in `config/database.yml` is correct for your platform.

    ```sh
    bundle exec rake db:setup
    bundle exec rake db:setup RAILS_ENV=test
    ```

    Ignore any errors from the second execution of `db:setup` for the test environment.

    **That should be it!  You are ready to develop.**

## Running MyUSA locally

From the command line in the Rails root, do the following:

```sh
bundle exec rails server
```

You can also do:

```sh
bundle exec rails s
```

(`s` is short for server).

Then, open your web browser and visit:

[http://localhost:3000/](http://localhost:3000/)

After you create a user account for yourself, be sure to [give one user administrative priviledges](https://github.com/18F/myusa/wiki/Administration).

When running the application in development mode, all emails and text messages are logged to the rails development log (often the terminal).

That's it!  Use MyUSA just as you would any other web application.

