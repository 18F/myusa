## MyUSA API Server

MyUSA is a platform for citizen identity.

## Getting Started

To get your Rails development environment setup, here's the steps to follow.


1. Install Dependencies.  These are the minimum versions supported.
      - Ruby 2.1.1
      - Rails 4.1.0
      - Git 1.9.2
      - MySQL 5.6

    [rbenv](https://github.com/sstephenson/rbenv) is convenient for managing Ruby/Rails versions.

2. Clone the `myusa-server` project

    In the directory where you want to store your development files, do the following:

    ```sh
    git clone https://github.com/18F/myusa-server.git
    ```

3. Install Ruby Gems

    Change into the directory (it would be `cd myusa-server` from wherever you executed the above command) and do the following:

    ```sh
    bundle install
    ```

    Note: MySQL must be previously installed for the mysql gem install to work

4. Create your configuration files

    ```sh
    cp config/database.yml.example config/database.yml
    cp config/secrets.yml.example config/secrets.yml
    rake secret
    ```

    Copy the result of the above rake command to the RAILS_SECRET_TOKEN variables in config/secrets.yml

5. Create the development and test databases

    Make sure you have MySQL running.  By default, the development environment looks to connect to MySQL using the root MySQL user with no password.

    ```sh
    bundle exec rake db:setup
    bundle exec rake db:setup RAILS_ENV=test
    ```
    
    Ignore any errors from the second execution of `db:setup` for the test environment.

    **That should be it!  You are ready to develop.**

## Running the MyUSA-server locally

Make sure you have MySQL running.  By default, the development environment
looks to connect to MySQL using the root MySQL user with no password.

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

That's it!  Use the app just as you would any other web application.

## Contributing to MyUSA

Please read the [MyUSA Contribution Guide](CONTRIBUTING.md) and submit a pull request.

## License

[The project is in the public domain](LICENSE.md), and all contributions will also be released in the public domain. By submitting a pull request, you are agreeing to waive all rights to your contribution under the terms of the [CC0 Public Domain Dedication](http://creativecommons.org/publicdomain/zero/1.0/).

This project constitutes an original work of the United States Government.
