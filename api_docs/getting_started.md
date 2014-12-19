# Group Getting Started

To make use of MyUSA services in your app, follow these steps:

## 1. Read these documents

In particular, take note of the various API calls which provide the functions
that your app will require.

## 2. Create your app

You can use any language or framework you choose; there are no restrictions on
platform or hosting for your app to be MyUSA-accessible. All we require is that
you make HTTPS calls to our REST API, and that your app provide an
OAuth2-compliant endpoint for a callback after the authentication process.
For a working example, take a look at [this minimal Ruby & Sinatra implementation](https://github.com/18F/omniauth-myusa/tree/master/example)
included in our [_omniauth-myusa_
repository](https://github.com/18F/omniauth-myusa).

## 3. Register your app

On the [Applications page](https://myusa-staging.18f.us/authorizations), click
the  "New Application" button. At minimum, you need to provide the following
information:
* **Name:** Since the application name will be shown to a user in their list
of authorizations, you should pick a name that's easily recognizable.
* **Redirect URI:** To authenticate a user, your app will direct the user's
browser to an authentication page at MyUSA. Once the user is authenticated,
MyUSA will redirect the user's browser to the URI you provide here.
* **Scopes:** You must select at least one scope which your app will use to
access user services.

After you've successfully submitted this form, you'll be given both a **Public
Key** (also known as the **Client ID**) and a **Secret Key**. Your app will
use these keys to access the MyUSA API. **Note that these keys cannot be
retrieved, only regenerated.**

Newly-registered applications start in **Private Mode**. In this mode, only the
registered developer of the app can access it through MyUSA.

## 4. Connect your app to MyUSA

Your app should feature a "Connect with MyUSA" button, which users can click to
sign in. See the [Authenticating Users](#authenticating-users) section for the
URL to use, and the [Branding](#branding) section for the HTML.

## 5. Test your app's connection to MyUSA

To ensure that everything's connected and functioning correctly, test these actions:

### Signing in

1. The "Connect with MyUSA" button should take you to a MyUSA sign in page.
1. Signing in with your MyUSA developer account (that is, the account used to
register the app) should bring you back to your app's OAuth callback endpoint.
1. Your app should create a local account associated with the MyUSA account's
ID; signing out and in again should use the same account, and not create a new
one.
1. If the app is still in **Private Mode**, signing in with any other account
should fail with a client authentication error.

### API access

Once a user has signed in, your app should have access to the specific scopes
requested, using the MyUSA API.
