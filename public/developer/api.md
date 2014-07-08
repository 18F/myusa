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


# Group Profile


## GET /api/profile

Get the user profile with attributes limited to just those chosen by app owner during app registration.

+ Response 200 (application/json; charset=utf-8)

    {
      "title": null,
      "first_name": "Joe",
      "middle_name": null,
      "last_name": "Citizen",
      "suffix": null,
      "address": null,
      "address2": null,
      "city": null,
      "state": null,
      "zip": null,
      "gender": null,
      "marital_status": null,
      "is_parent": null,
      "is_student": null,
      "is_veteran": null,
      "is_retired": "0",
      "email": "joe@citizen.org",
      "phone_number": null,
      "mobile_number": null,
      "uid": "76f5bb0a-e886-4ea9-b798-e9b9e164e54b",
      "id": "76f5bb0a-e886-4ea9-b798-e9b9e164e54b"
    }

## GET /api/profile?schema=

Get the user profile with attributes limited to just those chosen by app owner during app registration in schema format.

+ Parameters

 + schema (required, boolean, `true`)

+ Response 200 (application/json; charset=utf-8)

    {
      "email": "joe@citizen.org",
      "givenName": "Joe",
      "additionalName": null,
      "familyName": "Citizen",
      "homeLocation": {
        "streetAddress": "",
        "addressLocality": null,
        "addressRegion": null,
        "postalCode": null
      },
      "telephone": null,
      "gender": null
    }

# Group Task


## PUT /api/task/:id

Update a task

+ Parameters

 + name (optional, string, `Test task`) ...The updated name of the task.
 + task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute' }`)... The updated task items that are associated with the task.

+ Request Update a task and task items (application/json)

    {
      "task": {
        "name": "New Task",
        "task_items_attributes": [
          {
            "id": "1",
            "name": "Task item one"
          }
        ]
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": "2014-07-07T12:14:16.000Z",
      "user_id": 1,
      "created_at": "2014-07-08T12:14:16.000Z",
      "updated_at": "2014-07-08T12:14:16.558Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task item one",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T12:14:16.000Z",
          "updated_at": "2014-07-08T12:14:16.000Z"
        }
      ]
    }

## POST /api/tasks

Create a new task for the user for this application.

+ Parameters

 + name (required, string, `Test task`) ...The name for the task that is being created.
 + task_items_atributes(optional, hash, `{:id=>1, :name=>'Task attribute' }`) ...A list of task items to be associated with the task.

+ Request Create a new task (application/json)

    {
      "task": {
        "name": "New Task"
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-07-08T12:14:16.957Z",
      "updated_at": "2014-07-08T12:14:16.957Z",
      "app_id": 1,
      "task_items": [

      ]
    }

## GET /api/task/:id

Get a single task.

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-07-08T12:14:17.000Z",
      "updated_at": "2014-07-08T12:14:17.000Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task Item #1",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T12:14:17.000Z",
          "updated_at": "2014-07-08T12:14:17.000Z"
        },
        {
          "id": 2,
          "name": "Task Item #2",
          "url": "http://valid_url.com",
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T12:14:17.000Z",
          "updated_at": "2014-07-08T12:14:17.000Z"
        }
      ]
    }

## GET /api/tasks

List all tasks, and associated attributes, created by the calling application

+ Response 200 (application/json; charset=utf-8)

    [
      {
        "id": 1,
        "name": "Task #1",
        "completed_at": null,
        "user_id": 1,
        "created_at": "2014-07-08T12:14:17.000Z",
        "updated_at": "2014-07-08T12:14:17.000Z",
        "app_id": 1,
        "task_items": [
          {
            "id": 1,
            "name": "Task item 1 (no url)",
            "url": null,
            "completed_at": null,
            "task_id": 1,
            "created_at": "2014-07-08T12:14:17.000Z",
            "updated_at": "2014-07-08T12:14:17.000Z"
          }
        ]
      }
    ]

# Group Notification


## POST /api/notifications

This will create a notification for the authenticated user.  The user will be able to view the notification through a user interface, and optionally by email.

+ Parameters

 + subject (required, string, `Test notification`)
 + body (optional, string, `This is a test`)

+ Request Create a new notification (application/json)

    {
      "notification": {
        "subject": "Project MyUSA",
        "body": "This is a test."
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 17,
      "subject": "Project MyUSA",
      "body": "This is a test.",
      "received_at": "2014-07-08T12:14:14.017Z",
      "app_id": 1,
      "user_id": 1,
      "created_at": "2014-07-08T12:14:14.018Z",
      "updated_at": "2014-07-08T12:14:14.018Z",
      "deleted_at": null,
      "viewed_at": null
    }

