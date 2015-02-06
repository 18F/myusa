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
