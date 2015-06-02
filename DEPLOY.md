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
mysql2://[USER]:[PASSWORD]:[DB_HOST]:[DB_PORT]/[DB_NAME]
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

18F recommends HTTPS for all public-facing web applications, and uses AWS ELBs
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


## App Setup

### Initial installation

Once the external services have been created and configured, you can install
MyUSA to Cloud Foundry.

After locally cloning the [MyUSA repo](https://github.com/18F/myusa/),
follow the [18F Cloud Foundry Quick Deployment Guide](https://docs.18f.gov/apps/deployment/).

**Note:** For the initial installation, you need to supply two extra flags to
the `cf push` command, like so:

```
cf push myusa -n HOSTNAME --no-start
```

Use the `-n` flag to associate the app with a hostname other than `myusa` (for
example, `myusa-test`.)

Use the `--no-start` flag to ensure that the app doesn't attempt to start
after this first install, as the database hasn't been fully set up yet.

### Initial database setup

The MySQL database needs to be prepared with the correct schema before the
app can start.

1. Install the 18F version of the `cf-ssh` script, following
[these instructions](https://docs.18f.gov/getting-started/cf-ssh/)
2. Run the `cf-ssh` command once. It will fail with an error, but that's fine;
   we mainly need it to create the `myusa-ssh` app so that we can add the
   necessary environment variables.
3. Configure these environment variables for the `myusa-ssh` app with the
  correct settings:
  * `RAILS_ENV` (use `staging` or `production`)
  * `DATABASE_URL`
  * `SENDER_EMAIL`
  * `APP_HOST`
  Example command: `cf set-env myusa-ssh RAILS_ENV staging`
4. Run `cf restage myusa-ssh` to rebuild the droplet.
5. Run `cf-ssh` again. This time it should successfully build the application
   droplet and make an SSH connection to the container.
6. In the container, run: `bundle exec rake db:setup`
7. The database schema should now be built. Hit Control-D to quit.

### Deployment

Run `cf push` to deploy the application. Once deployment has completed, you
should be able to connect to it with a web browser.
