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


# Group Notification

## POST /api/v1/notifications

Create a notification

+ Request should create a new notification when the notification info is valid (application/json)

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
      "received_at": "2014-06-17T13:38:40.143Z",
      "app_id": 1,
      "user_id": 1,
      "created_at": "2014-06-17T13:38:40.144Z",
      "updated_at": "2014-06-17T13:38:40.144Z",
      "deleted_at": null,
      "viewed_at": null
    }

+ Request should return an error message (application/json)

    {
      "notification": {
        "body": "This is a test."
      }
    }

+ Response 400 (application/json; charset=utf-8)

    {
      "message": {
        "subject": [
          "can't be blank"
        ]
      }
    }


# Group Profile


## GET /api/v1/profiles

List all profiles.

+ Response 200 (application/json; charset=utf-8)

    {
      "title": null,
      "first_name": "Joe",
      "middle_name": null,
      "last_name": null,
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
      "is_retired": null,
      "email": null,
      "phone_number": null,
      "mobile_number": null,
      "uid": "d553c6dd-e4cb-4827-8783-53dd65ff828e",
      "id": "d553c6dd-e4cb-4827-8783-53dd65ff828e"
    }

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
      "uid": "609b93c1-450f-406d-bd01-06a72044ee5f",
      "id": "609b93c1-450f-406d-bd01-06a72044ee5f"
    }

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


## POST /api/v1/tasks

Create a task

+ Request should create a new task for the user (application/json)

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
      "created_at": "2014-06-17T13:38:23.082Z",
      "updated_at": "2014-06-17T13:38:23.082Z",
      "app_id": 1,
      "task_items": [

      ]
    }

+ Response 400 (application/json; charset=utf-8)

    {
      "message": "can't be blank"
    }

## PUT /api/v1/task/:id

Update a task.

+ Request should no longer be marked as complete when specified (application/json)

    {
      "task": {
        "name": "New Incomplete Task",
        "completed_at": null,
        "task_items_attributes": [
          {
            "id": "2",
            "name": "Task item one"
          }
        ]
      }
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 2,
      "name": "New Incomplete Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-06-17T13:38:25.000Z",
      "updated_at": "2014-06-17T13:38:26.010Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 2,
          "name": "Task item one",
          "url": null,
          "completed_at": "2014-06-17T13:38:25.000Z",
          "task_id": 2,
          "created_at": "2014-06-17T13:38:25.000Z",
          "updated_at": "2014-06-17T13:38:25.000Z"
        }
      ]
    }

+ Request should return meaningful errors (application/json)

    {
      "task": {
        "name": "New Task",
        "task_items_attributes": [
          {
            "id": "chicken",
            "name": "updated task item name"
          }
        ]
      }
    }

+ Response 422 (application/json; charset=utf-8)

    {
      "message": "Invalid parameters. Check your values and try again."
    }

+ Request should update the task and task items (application/json)

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
      "completed_at": "2014-06-16T13:38:28.000Z",
      "user_id": 1,
      "created_at": "2014-06-17T13:38:28.000Z",
      "updated_at": "2014-06-17T13:38:28.231Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task item one",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-17T13:38:28.000Z",
          "updated_at": "2014-06-17T13:38:28.000Z"
        }
      ]
    }

## GET /api/v1/tasks

List all tasks.

+ Response 200 (application/json; charset=utf-8)

    [
      {
        "id": 1,
        "name": "Task #1",
        "completed_at": null,
        "user_id": 1,
        "created_at": "2014-06-17T13:38:32.000Z",
        "updated_at": "2014-06-17T13:38:32.000Z",
        "app_id": 1,
        "task_items": [
          {
            "id": 1,
            "name": "Task item 1 (no url)",
            "url": null,
            "completed_at": null,
            "task_id": 1,
            "created_at": "2014-06-17T13:38:32.000Z",
            "updated_at": "2014-06-17T13:38:32.000Z"
          }
        ]
      }
    ]

+ Response 200 (application/json; charset=utf-8)

    [
      {
        "id": 1,
        "name": "Task #1",
        "completed_at": null,
        "user_id": 1,
        "created_at": "2014-06-17T13:38:33.000Z",
        "updated_at": "2014-06-17T13:38:33.000Z",
        "app_id": 1,
        "task_items": [
          {
            "id": 1,
            "name": "Task item 1 (no url)",
            "url": null,
            "completed_at": null,
            "task_id": 1,
            "created_at": "2014-06-17T13:38:33.000Z",
            "updated_at": "2014-06-17T13:38:33.000Z"
          }
        ]
      }
    ]

## GET /api/v1/task/:id

Retrieve a task.

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-06-17T13:38:33.000Z",
      "updated_at": "2014-06-17T13:38:33.000Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task Item #1",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-17T13:38:33.000Z",
          "updated_at": "2014-06-17T13:38:33.000Z"
        },
        {
          "id": 2,
          "name": "Task Item #2",
          "url": "http://valid_url.com",
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-06-17T13:38:33.000Z",
          "updated_at": "2014-06-17T13:38:33.000Z"
        }
      ]
    }

