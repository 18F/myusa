## MyUSA

MyUSA is a platform for citizen identity.

## Getting Started

To get your Rails development environment setup, here's the steps to follow.

    1.  Install Dependencies.  These are the minimum versions supported.

        MySQL 5.6
        Ruby 2.1.1
        Rails 4.1.0
        Git 1.9.2

        [rbenv](https://github.com/sstephenson/rbenv) is convenient for managing Ruby/Rails versions.

    2.  Clone the myusa-server project

      In the directory where you want to store your development files, do the following:

        git clone https://github.com/18F/myusa-server.git

    3.  bundle install

      Change into the directory (it would be 'cd myusa-server' from wherever you executed the above command) and do the following:

        bundle install

      Note: MySQL must be previously installed for the mysql gem install to work

    4.  Create your configuration files

        cp config/database.yml.example config/database.yml
        cp config/secrets.yml.example config/secrets.yml
        rake secret
        (copy the result of the above rake command to the RAILS_SECRET_TOKEN variable in config/secrets.yml)

    5.  Create the development and test databases

      Make sure you have MySQL running.  By default, the development environment looks to connect to MySQL using the root MySQL user with no password.

        bundle exec rake db:create
        bundle exec rake db:schema:load

That should be it!  You are ready to develop.

## Running the app locally

Make sure you have MySQL running.  By default, the development environment
looks to connect to MySQL using the root MySQL user with no password.

From the command line in the Rails root, do the following:

    rails server

You can also do:

    rails s

('s' is short for server).

Then, open your favorite web browser (if your favorite web browser is not
Chrome, reexamine your life) and visit:

    http://localhost:3000/

That's it!  Use the app just as you would any other web application.

## Developing

Check out the [MyUSA Contribution Guide](CONTRIBUTING.md)

## License

This project constitutes an original work of the United States Government.

You may use this project under the [MIT License](LICENSE).
