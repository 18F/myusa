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

After you create a user account for yourself, be sure to [give one user administrative priviledges](https://github.com/18F/myusa/wiki/Administration).

When running the application in development mode, all emails and text messages are logged to the rails development log (often the terminal).

That's it!  Use MyUSA just as you would any other web application.

## Creating an Amazon Web Services EC2 host

**NOTE:** For this example setup, we're going to assume that you're creating
a staging environment (i.e. `RAILS_ENV` will be set to `staging`). Wherever
we use `<env>` in the directions below, substitute either `staging` or whatever
other environment you're using (alternatives being `development` or
`production`.)

Set up environment variables containing your AWS keys:

```sh
export AWS_ACCESS_KEY=<key>
export AWS_SECRET_KEY=<secret>
```

Set up your `knife` configuration:

```sh
cp .chef/knife.rb.example .chef/knife.rb
```

Create a data bag key. You'll use this key to encrypt secrets that are
decrypted on the deployment hosts, so keep it somewhere safe:
```sh
openssl rand -base64 512 | tr -d '\r\n' > .databag_secret
```

Create an initial data bag for the environment, based on our example:

```sh
knife solo data bag create <env> myusa --json-file kitchen/secrets.json.example
```

Our defaults for encryption and passwords should work fine for testing. However,
you may want to change them, or add credentials for Amazon SES (mail service)
or Google (authentication). To edit the file:

```sh
knife solo data bag edit secrets myusa
```

Each ec2 node you're planning to deploy needs its own JSON file in the `nodes/`
folder. Each node can take one of three available roles:
* Database server
* App server
* "All-in-one" (app and database on the same node)

The "All-in-one" role is the simplest, as you can get MyUSA running on a single
machine. (This is the same role used for Vagrant.)

For separate app & database hosts, you need to deploy the database first,
then configure the app node file(s) to point to the database's address before
deployment.

For each host, create a JSON node file:
```sh
cp kitchen/nodes/<host type>.json.example kitchen/nodes/<host name>.json
```

Note that `app` and `all-in-one` node files have placeholders that need to be
filled out before they can be used:
 * `SSH PUBLIC KEY GOES HERE`: So the deployment script can log in as the
   `myusa` user.
 * `DATABASE ADDRESS GOES HERE`: So the app server can connect to the database.
   (This is only needed in the `app` node file.)

Then use `knife` to create each EC2 host and build the environment:

```sh
bundle exec knife ec2 server create \
    --groups <your security group> \
    --identity-file <path to your key pair file> \
    --ssh-key <your AWS key pair name> \
    --ssh-user ubuntu \
    --node-name <host name>
```

**Regarding security groups:** If you're deploying separate app and database
nodes, bear in mind that your database needs its MySQL port to be accessible.
You may want to create separate security groups for the app and the database.

## Deploying to Amazon Web Services with Capistrano

A few simple commands can deploy to a running AWS instance.

To set up a configuration for a particular environment, create the config file
from the EC2 example and name it after the environment...

```sh
cp config/deploy/ec2.rb.example config/deploy/<env>.rb
```

**NOTE:** If you've chosen an environment other than `staging`, edit the file
you just created above and change this line:
```ruby
set :rails_env, :staging
```

The EC2 example gets the target app server address from the `MYUSA_APP_HOST`
environment variable. (Alternatively, you can edit the new configuration file directly.)

```sh
export MYUSA_APP_HOST=<app_server_address>
```

Here's the basic `cap deploy` command. Use this to deploy the `devel` branch
and restart the web & app server processes.

```sh
bundle exec cap <env> deploy
```

If this is your first time deploying to this database, *or* if you've made
code changes that include database schema migrations, you need to run a
migration:

```sh
bundle exec cap <env> deploy:migrate
```

To deploy a branch other than `devel`, use the `BRANCH` environment variable:
```sh
BRANCH=feature/my-lovely-branch cap staging deploy
```

## Deploying through a Gateway

If your target deployment hosts are not directly reachable from your source
host (e.g. they're on a private subnet inside an Amazon VPC), you'll need
to use a gateway host as a midpoint. For the techniques described here to
work, **all** of the points below must be true:

* The gateway is reachable by SSH from your source host
* The target hosts are reachable by SSH from the gateway
* There are user accounts on the gateway with the same names as the accounts
  used by Chef and Capistrano on the target hosts *(this shouldn't normally
  be necessary, but we found that Chef had problems otherwise)*
* The required SSH public key is installed in all user accounts used for
  deployment, included the aforementioned accounts on the gateway
* The public key has been added to the shell session on the source host (using,
  for example, `ssh-add -K <key path>`
* Your local `.chef/knife.rb` file is based on `.chef/knife.rb.example`
* Your local `config/deploy/<environment>.rb` file is based on
  `config/deploy/ec2.rb.example`

The example config files we've provided for Chef and Capistrano check the
`MYUSA_GATEWAY` environment variable for the user and host details. So:

```sh
export MYUSA_GATEWAY=<user>@<host>
```

Once this is set, all the above deployment commands should use the gateway
automatically.
