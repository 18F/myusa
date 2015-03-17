FORMAT: 1A

# MyUSA API Documentation

# Group Overview

MyUSA is an openly accessible service designed to make life easier for app developers and users. It provides:
* **an Authentication and Authorization gateway**, which means apps don't need their own sign-in/sign-up screens
* **a Profile system**, which helps users save time as they fill out forms
* **a Notification service**, making it fast and free for apps to send email and SMS notifications to specific users

# Group Getting Started

Welcome to MyUSA’s API documentation. Here, you’ll find everything you need to know to successfully integrate MyUSA with your application.

To make use of MyUSA’s services in your application, follow the steps outlined below.
If you have questions or need more information, contact us – we’ll get back to you as quickly as we can.

## 1. Read these documents

Before doing anything else, read all of steps described in this document. In particular, take note of the various API calls that provide the functions your application requires.

## 2. Create your app

Use any language or framework you like to create your application – MyUSA places no restrictions on platform or hosting options. We have only two requirements:

* Your application must make HTTPS calls to our REST API
* Your application must provide an OAuth2-compliant endpoint for a callback after the authentication process

For a working example, take a look at [this minimal Ruby & Sinatra implementation](https://github.com/18F/omniauth-myusa/tree/master/example),
which is included in our [_omniauth-myusa_
repository](https://github.com/18F/omniauth-myusa).

## 3. Register your app

Once you’ve created your application, you’ll need to register it with MyUSA. To do this, visit our [Applications page](/authorizations) and click the green New Application button at the top-right corner of the screen. This will open a form you’ll need to complete in order to register your application. We encourage you to complete the form in its entirety. That said, only the following fields are required:

* **Name:** Enter the name of your application. Because your application’s name will appear in each user’s list of authorizations, you should choose a name that’s descriptive and easily recognizable.
* **Redirect URI:** Your application will direct each user's browser to an authentication page at MyUSA. Once the user has been authenticated, MyUSA will redirect the user's browser to the URI you provide here.
* **Scopes:** The latter portion of the form features a list of all the scopes available for use by your application. You’re free to select as many scopes as you like, but you’re required to select at least one to allow your application to access user services.

Please note that there are three levels of scopes:

1. Those you specify (indicate interest in accessing) when you register your application;
2. Those you request from the user during the OAuth process; and
3. Those the user approves access to during the OAuth process.

It’s possible that the user will deny access to some of the scopes you request. Currently, you’re required to specify at least one scope.

After you've completed and successfully submitted your application form, a **Public Key** (also known as the **Client ID**) and a Secret Key will be displayed on the page. Your application will use these keys to access the MyUSA API. Please note that **these keys cannot be retrieved, only regenerated** – please keep track of this information when you’re given access to it.

## 4. Make your application public
On the [Applications page](/authorizations), click
the  "New Application" button. At minimum, you need to provide the following
information:
* **Name:** Since the application name will be shown to a user in their list
of authorizations, you should pick a name that's easily recognizable.
* **Redirect URI:** To authenticate a user, your app will direct the user's
browser to an authentication page at MyUSA. Once the user is authenticated,
MyUSA will redirect the user's browser to the URI you provide here.
* **Scopes:** You must select at least one scope which your app will use to
access user services.

It’s important to note that all newly registered applications default to Private Mode. Applications in **Private Mode** are only able to be accessed (through MyUSA) by you, the registered developer. To enable user access to your application, you must request public access for it. Once this request is approved and access is granted, MyUSA users will be able to access your application.

## 5. Connect your application to MyUSA

After you’ve successfully registered your application, you’re ready to connect it to MyUSA. To do this, you’ll need to add a Connect with MyUSA button, which your users will click to log in.

Please visit the [Authenticating Users](#authenticating-users) section to access the URL to use, and visit our [Branding](#branding) section to access the HTML you’ll need to install the MyUSA button.

## 6. Test your app's connection to MyUSA

To ensure that your application is properly connected to MyUSA, test its login capability and API access by taking the actions described below:

### Signing in

1. Access your application and click the Connect with MyUSA button as it appears in your application. You should be taken to the MyUSA sign in page.
1. Sign in with your MyUSA developer account (the one you used to register your application). Doing this should route you to your application's OAuth callback endpoint.
1. Be aware that your application is in Private Mode by default. As long as your application remains in **Private Mode**, your attempts to sign in with any other account should produce a client authentication error.

### API access

Once a user has signed in, your app should have access to the specific scopes
requested, using the MyUSA API.

# Group Branding Guidelines

These guidelines provide the design specifications for using the MyUSA brand
within your application.  You can use these assets on your website or in your
application so long as they comply with the MyUSA Terms of Service.

The use of the MyUSA brand in any way not disclosed in this document or the
Terms of Services requires explicit approval.  Note that the MyUSA brand or
any affiliated government organization may not be used to imply an
endorsement of an organization (including a nonprofit), product, person,
or service.

## MyUSA Button

Two versions of the MyUSA button are available: one with a blue background and one with a white background.

**Note:** In the HTML code below, replace `$URL` with your custom sign in URL. (See [the "Authenticating Users" section](#authenticating-users) for more information.)

### Blue Background

<a href="" class="btn btn-social btn-myusa">Connect with MyUSA</a>

To add this button to your application, use the following HTML:

```html
<link href='//fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>
<link href='//s3.amazonaws.com/myusa-static/button.min.css' rel='stylesheet' type='text/css'>
<p>
<a href="$URL" class="btn btn-social btn-myusa">Connect with MyUSA</a>
</p>
```

### White Background

<a href="" class="btn btn-social btn-myusa white">Connect with MyUSA</a>

To add this button to your application, use the following HTML:

```html
<link href='//fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>
<link href='//s3.amazonaws.com/myusa-static/button.min.css' rel='stylesheet' type='text/css'>
<p>
<a href="$URL" class="btn btn-social btn-myusa white">Connect with MyUSA</a>
</p>
```


# Group Authentication

MyUSA uses OAuth 2.0. The authentication flow is as follows:

1. Your application redirects the user to MyUSA.
1. If the user is not logged in at MyUSA, they are redirected to a login dialog.
1. The user authorizes MyUSA to grant access to your application.
1. MyUSA redirects the user back to your application, with an access_token.
1. Using the access token, your application may query MyUSA APIs that you granted access to.

## Scopes

The scopes you define when you setup your app on MyUSA.gov define what information users will be asked to grant access to. Scopes limit access for OAuth tokens. They do not grant any additional permission beyond that which the user already has.

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

1. Sign in to [MyUSA](/) to register an application.
1. Provide a redirect URI which is `YOUR_SITE/auth/myusa/callback` by default.
1. Select the scopes that your application will request. Sample scopes are email `profile.first_name` and `profile.phone_number`.
1. Take note of your Consumer Key and Consumer Secret.

## Authenticating Users

To sign in to your app, users should be shown a "Connect with MyUSA" button. (See the [Branding section](#branding) for details and code.) The button should link to your app's custom sign in URL, which you can construct from this format:
```
    https://my.usa.gov/users/sign_in?client_id=ABCD
```

... where `ABCD` should be replaced with the **Consumer Public Key** (also known as the **Client ID**) that MyUSA provided when your app was registered.

After clicking the "Connect with MyUSA" button, the user will be presented with the MyUSA login page. When they login, they will be redirected back to your application via the redirect URI that you specified when you setup the application. If your redirect uri was `https://www.example.com/test`, MyUSA would redirect to:

```
https://www.example.com/test?code=12345abcde
```

### Handling the response

Your application should have an end point to recieve the redirect at this url.

### Long-lived Token

Now that you have a valid code, you can make a server to server request to the MyUSA API to get a long-lived token to keep users logged in.


## Example Rails configuration

Start by adding this gem to your Gemfile:

```ruby
gem 'omniauth-myusa', :git => 'https://github.com/18F/omniauth-myusa'
```

Next, tell OmniAuth about this provider. For a Rails app, your `config/initializers/omniauth.rb` file should look like this:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :myusa, "YOURKEY", "YOURSECRET", scope: [...]
end
```

Set SCOPES equal to a space separated string of your scopes that you requested when you created the app. In the future, we will generate this for you.
Replace CONSUMER_KEY and CONSUMER_SECRET with the appropriate values you obtained from [MyUSA](/authorizations) earlier.

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

## POST /oauth/token

+ Request Requesting the access token
    {
      "client_id": THE_ID,
      "client_secret": THE_SECRET,
      "code": RETURNED_CODE,
      "grant_type": "authorization_code",
      "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "access_token": "...",
      "token_type": "bearer",
      "expires_in": 7200,
      "refresh_token": "..."
    }

+ Request Refreshing the access token
    {
      "client_id": THE_ID,
      "client_secret": THE_SECRET,
      "refresh_token": REFRESH_TOKEN,
      "grant_type": "refresh_token",
      "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"
    }

+ Response 200 (application/json; charset=utf-8)

    {
      "access_token": "...",
      "token_type": "bearer",
      "expires_in": 7200,
      "refresh_token": "..."
    }

## POST /oauth/revoke

+ Request Revoking the token
    {
      "token": TOKEN
    }

+ Response 200 (application/json; charset=utf-8)

  Always returns a 200, even if the token does not exist or has already been revoked.


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


# Group Logout


## GET /users/sign_out?continue=

Log the current user out and end the user's MyUSA session.  With the `continue`
parameter and a valid URL, the user is returned to the URL indicated.  To be
valid, the hostname must be in the same domain (an extension of) the OAuth
application's registered URL.  The OAuth application must also be approved by
the user.

+ Parameters

 + continue (required, url, `http://example.com/page`)

+ Response 302
    + Headers

        Location: http://example.com/page


## GET /users/sign_out

Log the current user out and end the user's MyUSA session.  Without any
parameters, this returns the user to the root page, e.g. http://my.usa.gov/

+ Response 302

