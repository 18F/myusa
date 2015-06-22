# MyUSA Configuration Environment Variables

| Variable name | Example value | Purpose |
| ------------- | ------------- | ---------- |
| `RAILS_ENV` | `staging` | Tells Rails which environment config to use. At present `staging` and `production` have identical config files, since they pull the actual config variables from the environment. If you're developing on a local machine, use `development`. |
| `APP_HOST` | `myusa-staging.18f.gov` | App hostname. Used by the email-sender when creating token links, also in the `From:` address |
| `APP_PROTOCOL` | `https` | App URL protocol. Used by the email-sender when creating token links. |
| `SECRET_KEY_BASE` | `abcdef123456` | Secret hex string used by Devise to sign session cookies |
| `DATABASE_URL` | `mysql2://myusa:password@myusa-db.us-east-1.rds.amazonaws.com:3306/myusa` | DB connection string; needed for CloudFoundry. Otherwise, MyUSA will attempt to use existing the `config/database.yml` file. |
| `DB_ENCRYPT_KEY` | `abcdef123456` | Secret hex string used to en/decrypt DB data |
| *`ELASTICACHE_ENDPOINT`* | `myu-el-1fv3zquvafith.tbqtii.cfg.use1.cache.amazonaws.com` | Optional: AWS ElastiCache configuration endpoint (without port number) |
| `SENDER_EMAIL` | `myusa@gsa.gov` | Email sender address for non-notification emails |
| `SMTP_HOST` | `email-smtp.us-east-1.amazonaws.com` | Used for outbound email |
| `SMTP_PORT` | `443` | Used for outbound email |
| `SMTP_USER` | `gsauser` | Credential for outbound email server |
| `SMTP_PASS` | `password` | Credential for outbound email server |
| `SMS_NUMBER` | `+12407433320` | Sender number for outbound SMS messages |
| `TWILIO_ACCOUNT_SID` | `ACabcdef123456` | Account ID for Twilio SMS API |
| `TWILIO_AUTH_TOKEN` | `abcdef123456` | Secret key for Twilio SMS API |
| `OMNIAUTH_GOOGLE_APP_ID` | `abcdef-123456.apps.googleusercontent.com` | Account ID for Google Sign-In API |
| `OMNIAUTH_GOOGLE_SECRET` | `wxyz-1234-abcdef` | Secret key for Google Sign-In API |
| *`NEW_RELIC_APP_NAME`* | `MyUSA` | Identifies app data in New Relic dashboard |
| *`NEW_RELIC_LICENSE_KEY`* | `abcdef123456` | Secret API key for New Relic |
| *`VERBOSE`* | `true` | Tells Cloud Foundry to log more app output (for debugging) |
| *`FORCE_HTTPS`* | `true` | Tells Cloud Foundry to force HTTPS for app requests |
