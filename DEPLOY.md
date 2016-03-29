# MyUSA Deployment Guide

MyUSA can be deployed in most UNIX-like environments that support Ruby 2.1.
However, its primary deployment target is the 18F.gov cloud, running
Cloud Foundry 2.0 on Ubuntu Linux. This deployment guide is aimed at
that environment.

## Requisites

In order to push the application to Cloud Foundry, you will need:

* The Cloud Foundry CLI tools installed on your local machine, and configured
  to log into the 18F cloud
  (see [this guide](https://docs.18f.gov/getting-started/setup/) )
* a Cloud Foundry Organization and Spaces in which the app will be deployed
  (see [this guide](https://docs.18f.gov/getting-started/concepts/) )
* a `SpaceDeveloper` role for your account in the given Space

**Note:** We recommend creating separate Spaces for each deployment
environment, e.g. `production` and `staging`.

## Order of Setup

**Note:** The instructions below use some placeholders in the commands, which you should replace with the correct values when entered. Those placeholders are:

| Placeholder | Example | Purpose |
| ----------- | ------- | ------- |
| $SPACENAME  | `staging` | Cloud Foundry Space housing the application |
| $HOSTNAME | `myusa-staging` | Hostname of the application |
| $DOMAIN  | `18f.gov` | Domain name in which the hostname will be added |
| $DATABASE_URL | `mysql2://...` | [Database connection string](#mysql-database) |

You may find it easier to set variables in your local environment so you can just copy and paste the commands below.

_These instructions are based on the [18F Cloud Foundry Quick Deployment Guide](https://docs.18f.gov/apps/deployment/). Take a look at them if you run into trouble._

1. Locally clone the MyUSA repo:

    ```
    git clone git@github.com:18f/myusa; cd myusa
    ```

1. Create a Space within the Org:

    ```
    cf create-space $SPACENAME
    ```
1. Do an initial push to add the application to the space:

    ```
    cf push myusa -n $HOSTNAME --no-start
    ```
(This push may well fail due to missing environment variables, but the purpose is to create the `myusa` app in our Space)
1. This next set of steps is all about furnishing the database with the app's schema.
  1. First, ensure that the database exists and is available - see [the _MySQL Database_ section below](#mysql-database). Assemble the connection info into a $DATABASE_URL string - we'll be using it in a moment when setting up the environment variables for the app.
  1. Create the initial `myusa-ssh` setup:

        ```
        cf-ssh
        ```
  (It will likely fail with an error, but after creating the app)
  1. Add the four necessary CF environment variables to `myusa-ssh`:

        ```
        cf set-env myusa-ssh APP_HOST $HOSTNAME.$DOMAIN
        cf set-env myusa-ssh SENDER_EMAIL 'myusa-sender@gsa.gov'
        cf set-env myusa-ssh DATABASE_URL $DATABASE_URL
        cf set-env myusa-ssh RAILS_ENV staging
        cf restage myusa-ssh
        ```
  1. Open the remote shell session:

        ```
        cf-ssh
        ```
  1. Inside that session, tell Rails to set up the database with the app schema:

        ```
        bundle exec rake db:setup
        ```
  1. The database schema should now be built. Hit Control-D to quit.
1. Now that we have the database set up, configure the environment variables for the main application/ At minimum you'll need the four specified above for the database setup, but ideally you should add as many of those specified in [the _External Services_ section](#external-services) as possible. For each variable, set it for the app like so:

    ```
    cf set-env myusa VARIABLE_NAME VARIABLE_VALUE
    ```
1. Check the enviroment variables you've set:

    ```
    cf env myusa
    ```
1. Restage to export the variables to the app:

    ```
    cf restage myusa
    ```
1. Finally, push to launch:

    ```
    cf push myusa -n $HOSTNAME
    ```

The app should now be available at `https://$HOSTNAME.$DOMAIN/`

## External Services

MyUSA relies on the following external services for its functionality. Except
where otherwise noted, the external service setup is required in advance,
then configured through
[user-provided CF environment variables](http://docs.cloudfoundry.org/devguide/deploy-apps/environment-variable.html).
The variables needed are listed below with their associated services; for
a full list, see [CONFIGURATION.md](CONFIGURATION.md).

### MySQL Database

MyUSA has been tested with a standard MySQL 5.6 installation. It only requires
a single database (typically named `myusa`) with a single database user.

Database access is configured through the `DATABASE_URL` variable, in this
format:
```
mysql2://[USER]:[PASSWORD]@[DB_HOST]:[DB_PORT]/[DB_NAME]
```
for example:
```
mysql2://myusa:passw0rd@myusa.us-east-1.rds.amazonaws.com:3306/myusa
```

MyUSA encrypts various sensitive data fields before storage in the
database, using a secret key stored in the `DB_ENCRYPT_KEY` variable.

Summary of environment variables needed:

| Variable name | Example value | Purpose |
| ------------- | ------------- | ---------- |
| `DATABASE_URL` | `mysql2://myusa:password@myusa-db.us-east-1.rds.amazonaws.com:3306/myusa` | DB connection string; needed for CloudFoundry. Otherwise, MyUSA will attempt to use existing the `config/database.yml` file. |
| `DB_ENCRYPT_KEY` | `abcdef123456` | Secret hex string used to en/decrypt DB data |

To create a database instance in AWS:

Set up an RDS instance of a standard MySQL 5.6 in the CloudFoundry-live subnet, with the Cloud Foundry security group set. The one tweak you do need to make in setup is using the “utf8” DB Parameter Group (which is likely in the Advanced Settings just before you hit Go).

### Elastic Load Balancer

18F requires HTTPS for all public-facing web applications, and uses AWS ELBs
for load-balancing and SSL termination. Use
[this guide](https://docs.18f.gov/ops/elb/) to set up an ELB for your MyUSA
deployment.

### Outbound Email Delivery (SMTP)

MyUSA sends email to users as part of the typical authentication process.
Since these emails include links back to the web application, the app
needs to be configured with the correct address.

These are the environment variables to configure:

| Variable name | Example value | Purpose |
| ------------- | ------------- | ---------- |
| `APP_HOST` | `myusa-staging.18f.gov` | App hostname. Used by the email-sender when creating token links, also in the `From:` address |
| `APP_PROTOCOL` | `https` | App URL protocol. Used by the email-sender when creating token links. |
| `SENDER_EMAIL` | `myusa@gsa.gov` | Email sender address for non-notification emails |
| `SMTP_HOST` | `smtp.mandrillapp.com` | Used for outbound email |
| `SMTP_PORT` | `443` | Used for outbound email |
| `SMTP_USER` | `gsauser` | Credential for outbound email server |
| `SMTP_PASS` | `password` | Credential for outbound email server |

### Outbound SMS Delivery

MyUSA sends SMS messages for Two-Factor Authentication (2FA). It expects to
use the [Twilio](https://www.twilio.com) service.

These are the environment variables to configure:

| Variable name | Example value | Purpose |
| ------------- | ------------- | ---------- |
| `SMS_NUMBER` | `+12407433320` | Sender number for outbound SMS messages |
| `TWILIO_ACCOUNT_SID` | `ACabcdef123456` | Account ID for Twilio SMS API |


### Google Sign-In

MyUSA allows authentication with Google as an alternative to email-based
authentication. If you don't have one yet, create a Google Developers Console
Project through
[their site](https://developers.google.com/identity/sign-in/web/devconsole-project),
then configure these environment variables:

| Variable name | Example value | Purpose |
| ------------- | ------------- | ---------- |
| `OMNIAUTH_GOOGLE_APP_ID` | `abcdef-123456.apps.googleusercontent.com` | Account ID for Google Sign-In API |
| `OMNIAUTH_GOOGLE_SECRET` | `wxyz-1234-abcdef` | Secret key for Google Sign-In API |

### ElastiCache (optional)

Though not enforced, we strongly recommend use of the
[AWS ElastiCache service](http://aws.amazon.com/elasticache/)
to share user session data between app workers.

| Variable name | Example value | Purpose |
| ------------- | ------------- | ---------- |
| `ELASTICACHE_ENDPOINT` | `myu-el-1fv3zquvafith.tbqtii.cfg.use1.cache.amazonaws.com` | Optional: AWS ElastiCache configuration endpoint (without port number) |

### New Relic (optional)

MyUSA is able to send errors and other performance data to New Relic for
monitoring and debugging purposes. We recommend this, as it's saved
us large amounts of pain.

| Variable name | Example value | Purpose |
| ------------- | ------------- | ---------- |
| `NEW_RELIC_APP_NAME` | `MyUSA` | Identifies app data in New Relic dashboard |
| `NEW_RELIC_LICENSE_KEY` | `abcdef123456` | Secret API key for New Relic |
