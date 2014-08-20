FORMAT: 1A

# MyUSA API Documentation

# Group Authentication

# Getting started with MyUSA Authentication

MyUSA uses OAuth 2.0. To find out more information about MyUSA and how to create your own application visit the [developers](https://my.usa.gov/developer) section of MyUSA.

## Overview

1. Your application redirects the user to a login dialog at the MyUSA.gov.
2. The user authorizes MyUSA.gov.
3. MyUSA.gov redirects the user back to your application, with an access_token.
4. Your application validates the access token.
5. The access token allows your application to access scope information from MyUSA.gov.

## Scopes

The scopes you define when you setup your app on MyUSA.gov define what information your app will require from the user. Scopes limit access for OAuth tokens. They do not grant any additional permission beyond that which the user already has.

## API Versions

To access the MyUSA API, your app should use URLs which include the API version number.
API URLs are constructed using this template:
```
https://my.usa.gov/api/[VERSION]/[ENDPOINT]
```

The MyUSA API is currently at **version 1**. So, to access the Profile API, request this URL:
```
https://my.usa.gov/api/v1/profile
```

The MyUSA team frequently makes minor changes to the API, but the vast majority of these changes are backwards-compatible and will not break existing integration code.

If an API change is backwards-incompatible, we increment the version number while keeping the previous version available.
By using API URLs with specified versions, your application can continue operating without code changes.

**Note that only two versions of the API are officially supported at any time: the current version, and the version preceding it.**
If your app uses the MyUSA API, you'll need to keep track of new versions to ensure that the app stays functional.

## Connecting with OAuth

1. Sign in to [MyUSA](https://my.usa.gov/developer) to register an application.
2. Provide a redirect URI which is `YOUR_SITE/auth/myusa/callback` by default.
3. Select the scopes you wish to recieve about user data. Sample scopes are email first_name and phone_number.
4. Take note of your Consumer Key and Consumer Secret.

## Your Application

First, direct your user to https://my.usa.gov/auth/myusa with the following parameters:

```
 MYUSA_CLIENT_ID
 REDIRECT_URI
 TYPE : CODE
```

At this point, the user will be presented with the myusa login page. When they login, they will be redirected back to your application via the redriect URI that you specified when you setup the application. If your redirect uri was `https://www.ryan.com/test`, MyUSA would redirect to:

```
https://www.ryan.com/test?code=12345abcde
```

### Handling the response

Your application should have an end point to recieve the redirect at this url.

### Long-lived Token

Now that you have a valid code, you can make a server to server request to `api.my.usa.gov` to get a long-lived token to keep users logged in.


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

# Group OAuth

## GET /api/v1/tokeninfo

Get metadata about the token used to make this request, including
the list of scopes the user has authorized.

+ Response 200 (application/json; charset=utf-8)

  {
    "resource_owner_id": 3879,
    "scopes": [
      "profile.first_name",
      "profile.last_name"
    ],
    "expires_in_seconds": 7200,
    "application": {
      "uid": "b6b334908bed08005ca145fc96ccbd7e4015a0e504d085c77298cf321aaca8f3"
    }
  }

# Group Profile


## GET /api/v1/profile?schema=

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

## GET /api/v1/profile

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
      "uid": "a83dead6-d98d-4377-9e69-eb00488839f5",
      "id": "a83dead6-d98d-4377-9e69-eb00488839f5"
    }

# Group Task


## PUT /api/v1/task/:id

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
      "completed_at": "2014-07-07T17:59:21.000Z",
      "user_id": 1,
      "created_at": "2014-07-08T17:59:21.000Z",
      "updated_at": "2014-07-08T17:59:21.875Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task item one",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T17:59:21.000Z",
          "updated_at": "2014-07-08T17:59:21.000Z"
        }
      ]
    }

## POST /api/v1/tasks

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
      "created_at": "2014-07-08T17:59:22.487Z",
      "updated_at": "2014-07-08T17:59:22.487Z",
      "app_id": 1,
      "task_items": [

      ]
    }

## GET /api/v1/tasks

List all tasks, and associated attributes, created by the calling application

+ Response 200 (application/json; charset=utf-8)

    [
      {
        "id": 1,
        "name": "Task #1",
        "completed_at": null,
        "user_id": 1,
        "created_at": "2014-07-08T17:59:23.000Z",
        "updated_at": "2014-07-08T17:59:23.000Z",
        "app_id": 1,
        "task_items": [
          {
            "id": 1,
            "name": "Task item 1 (no url)",
            "url": null,
            "completed_at": null,
            "task_id": 1,
            "created_at": "2014-07-08T17:59:23.000Z",
            "updated_at": "2014-07-08T17:59:23.000Z"
          }
        ]
      }
    ]

## GET /api/v1/task/:id

Get a single task.

+ Response 200 (application/json; charset=utf-8)

    {
      "id": 1,
      "name": "New Task",
      "completed_at": null,
      "user_id": 1,
      "created_at": "2014-07-08T17:59:23.000Z",
      "updated_at": "2014-07-08T17:59:23.000Z",
      "app_id": 1,
      "task_items": [
        {
          "id": 1,
          "name": "Task Item #1",
          "url": null,
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T17:59:23.000Z",
          "updated_at": "2014-07-08T17:59:23.000Z"
        },
        {
          "id": 2,
          "name": "Task Item #2",
          "url": "http://valid_url.com",
          "completed_at": null,
          "task_id": 1,
          "created_at": "2014-07-08T17:59:23.000Z",
          "updated_at": "2014-07-08T17:59:23.000Z"
        }
      ]
    }

# Group Notification


## POST /api/v1/notifications

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
      "received_at": "2014-07-08T17:59:15.803Z",
      "app_id": 1,
      "user_id": 1,
      "created_at": "2014-07-08T17:59:15.804Z",
      "updated_at": "2014-07-08T17:59:15.804Z",
      "deleted_at": null,
      "viewed_at": null
    }
