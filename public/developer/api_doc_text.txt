FORMAT: 1A

# MyUSA API Documentation

# Getting started with MyUSA Authentication

MyUSA uses OAuth 2.0. To find out more information about MyUSA and how to create your own application visit the [developers](https://my.usa.gov/developer) section of MyUSA.

## Overview

1. Your application redirects the user to a login dialog at the MyUSA.gov.
2. The user authorizes MyUSA.gov.
3. MyUSA.gov redirects the user back to your application, with an access_token.
4. Your application validates the access token.
5. The access token allows your application to access scope information from MyUSA.gov.

### Scopes

The scopes you define when you setup your app on MyUSA.gov define what information your app will require from the user. Scopes limit access for OAuth tokens. They do not grant any additional permission beyond that which the user already has.

## Before You Begin

1. Sign in to [MyUSA](https://my.usa.gov/developer) to register an application. 
2. Provide a redirect URI which is `YOUR_SITE/auth/myusa/callback` by default. 
3. Select the scopes you wish to recieve about user data. Sample scopes are email first_name and phone_number.
4. Take note of your Consumer Key and Consumer Secret.

## Your Application

First, direct your user to https://my.usa.gov/auth/myusa with the following parameters:

```
 MYGOV_CLIENT_ID 
 REDIRECT_URI 
 TYPE : CODE
```

At this point, the user will be presented with the myusa login page. When they login, they will be redirected back to your application via the redriect URI that you specified when you setup the application. If your redirect uri was www.ryan.com/test, MyUSA would redirect to:

```
https://www.ryan.com/test?code=12345abcde
```

### Handling the response

Your application should have an end point to recieve the redirect at this url. 

### Long Live Token

Now that you have a valid code, you can make a server to server request to `api.my.usa.gov` to get a long live token to keep users logged in. 


## Example Rails configuration

First start by adding this gem to your Gemfile:

```ruby
gem 'omniauth-myusa', :git => 'https://github.com/GSA-OCSIT/omniauth-myusa.git'
```

Next, tell OmniAuth about this provider. For a Rails app, your `config/initializers/omniauth.rb` file should look like this:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
 MYGOV_CLIENT_ID = "YOURKEY"
 MYGOV_SECRET_ID = "YOURSECRETKEY"
 MYGOV_HOME = 'http://my.usa.gov'
 SCOPES = "profile.email profile.title profile.first_name"
 provider :myusa, MYGOV_CLIENT_ID, MYGOV_SECRET_ID, :scope => SCOPES
end
```

Set SCOPES equal to a space separated string of your scopes that you requested when you created the app. In the future, we will generate this for you.
Replace CONSUMER_KEY and CONSUMER_SECRET with the appropriate values you obtained from [MyUSA](https://my.usa.gov/apps) earlier.

Don't forget to create a route to handle the callback. For example:

```
get '/auth/:provider/callback', to: 'sessions#create’
```

The sessions controller in this example calls a create method that logs in the user.


Further reading:

## Watch the RailsCast

Ryan Bates has put together an excellent RailsCast on OmniAuth:

[![RailsCast #241](http://railscasts.com/static/episodes/stills/241-simple-omniauth-revised.png "RailsCast #241 - Simple OmniAuth (revised)")](http://railscasts.com/episodes/241-simple-omniauth-revised)

View the OmniAuth 1.0 docs for more information about strategy implementation: https://github.com/intridea/omniauth.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


