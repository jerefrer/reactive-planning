@Logger = new Loggly
  token: process.env.LOGGLY_TOKEN
  subdomain: process.env.LOGGLY_SUBDOMAIN
  auth:
    username: process.env.LOGGLY_USERNAME
    password: process.env.LOGGLY_PASSWORD
