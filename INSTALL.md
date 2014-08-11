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

2. Clone the `myusa-server` project

    In the directory where you want to store your development files, do the following:

    ```sh
    git clone https://github.com/18F/myusa.git
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

    Copy the result of the above rake command to the `RAILS_SECRET_TOKEN` variables in `config/secrets.yml`

5. Create the development and test databases

    Make sure you have MySQL running.  By default, the development environment looks to connect to MySQL using the root MySQL user with no password.

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

That's it!  Use the app just as you would any other web application.

## Creating an Amazon Web Services EC2 host

First, set up environment variables containing your AWS keys:

```sh
export AWS_ACCESS_KEY=<key>
export AWS_SECRET_KEY=<secret>
```

Set up your `knife` configuration:

```sh
cp .chef/knife.rb.example .chef/knife.rb
```

... and a node configuration:

```sh
cp kitchen/nodes/ec2.json.example kitchen/nodes/YOUR-LOVELY-HOST.example
```

Then use `knife` to create an EC2 host and build the environment:

```sh
bundle exec knife ec2 server create \
    --groups YOUR-SECURITY-GROUP \
    --identity-file YOUR-KEY-PAIR.pem \
    --ssh-key YOUR-KEY-PAIR-NAME \
    --ssh-user ubuntu \
    --node-name YOUR-LOVELY-HOST
```

## Deploying to Amazon Web Services with Capistrano

A few simple commands can deploy to a running AWS instance.

To set up a configuration for a particular environment, create the config file
from the EC2 example and name it after the environment type; for example, `staging`:

```sh
cp config/deploy/ec2.rb.example config/deploy/staging.rb
```

The EC2 example gets the target server address from the `MYUSA_STAGING`
environment variable. (Alternatively, you can edit the new configuration file directly.)

```sh
export MYUSA_STAGING=<staging_server_address>
```

For your first deploy, run `deploy:setup`. This creates the necessary databases
and configuration files, then deploys the `devel` branch and restarts the
Rails server and web server processes.
```sh
bundle exec cap staging deploy:setup
```

Once `deploy:setup` has been run on a given host, all future deploys can
just use the `deploy` command:
```sh
bundle exec cap staging deploy
```

To deploy a branch other than `devel`, use the `BRANCH` environment variable:
```sh
BRANCH=feature/my-lovely-branch cap staging deploy
```
