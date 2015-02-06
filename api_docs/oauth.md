
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
    https://my.usa.gov/users/sign_in?login_reqired=true&client_id=ABCD
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
