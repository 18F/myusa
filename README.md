[![Build Status](https://api.travis-ci.org/GSA/mygov-account.png?branch=master)](http://travis-ci.org/GSA/mygov-account)

## MyUSA

MyUSA is a platform for citizen identity.

## Getting Started

To get your Rails development environment setup, here's the steps to follow.
We assume that you have MySQL installed.  If you don't, Google it and figure
it out.  We also assume you have git installed, if you don't, install it here:
https://help.github.com/articles/set-up-git

    1.  Install RVM

        curl -L https://get.rvm.io | bash -s stable --ruby

      Note: you may need to have previously installed
      MacPorts/Homebrew and other dependencies for rvm/ruby (on OS X at least)
      prior to running this command

    2.  Install the Ruby 1.9.3 rvm instance

        rvm install ruby-1.9.3

    3.  Clone the mygov project

      In some directory where you want to store your development files, do the following:

        git clone https://github.com/GSA/mygov-account.git

    4.  bundle install

      Change into the directory (it would be 'cd mygov' from wherever you executed the above command) and do the following:

        bundle install

      Note: MySQL must be previously installed for the mysql gem install to work

    5.  Create your configuration files

      cp config/database.yml.example config/database.yml
      cp config/twilio.yml.example config/twilio.yml
      cp config/resque.yml.example config/resque.yml
      cp config/initializers/01_mygov.rb.example config/initializers/01_mygov.rb
      (check these configuration files to ensure they look correct for your environment)
      rake secret
      (copy the result of the above rake command to the RAILS_SECRET_TOKEN variable in config/initializers/01_mygov.rb)

    6.  Create the development and test databases

      Make sure you have MySQL running.  By default, the development environment looks to connect to MySQL using the root MySQL user with no password.

        bundle exec rake db:create
        bundle exec rake db:schema:load
        bundle exec rake db:create RAILS_ENV=test
        bundle exec rake db:schema:load RAILS_ENV=test

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

Hopefully you now have the site running.  However, to be practical, you must perform 
one additional step with the current code base.  You need to approve yourself as 
a user.  Utilize the site to sign up with an email that you want to use.  Click on 
the confirmation link presented to you.  Then execute in MySQL in the mygov_development database:

     update beta_signups set is_approved = 1 where id=1;

(assuming that you are id # 1 in the beta_signups table.)

That's it!  Use the app just as you would any other web application.

## Developing

Check out the Rails documentation for information regarding creating models,
controllers, views, etc.

Before developing a new feature, it's a good idea to check out a branch to do
all your work in:

    git checkout -b myfeature

When you're done developing something, make sure all the tests still pass by
doing the following (from the Rails root):

    bundle exec rake spec

If specific tests are failing and you want to save time and zero in on just
those tests, do:

    bundle exec rspec spec/models/model_name.rb

When you have finished working on a feature, make your commit locally with
git:

    git add <your files>
    git commit -m"My commit message"

If you did the right thing and did your work in a branch, you should rebase on
master after you commit, and then merge your changes into master:

    git checkout master
    git pull origin master
    git checkout myfeature
    git rebase -i master
    (squish if you want; it's a good idea)
    git checkout master
    git merge myfeature

Then push your commit up to the github server so other developers can pull it
down:

    git push origin master

If you're really done with your feature, clean up your local branch:

    git branch -d myfeature

For more information on how to properly develop with git and feature branches,
see:

    http://blog.hasmanythrough.com/2008/12/18/agile-git-and-the-story-branch-pattern
