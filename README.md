## Usage

Once set up, this tool creates a liveblog that can be embedded via iframe byentering your designated Slack channel and typing `/start_liveblog <Name of your liveblog>`.

![image of liveblog start](http://files.adampash.com/s/Slack_1BF3A67D.png)

When you're done, type `/end_liveblog`. Pretty simple.

## Setup and installation

This set up assumes a few things:

1. You're deploying to Heroku
1. You are an admin on a Slack Team
1. You are using Fastly.
1. You are using an S3 bucket for assets.

The Fastly requirement is hard-coded at the moment. I'd be happy to take a pull request that makes it optional, but for a reasonably trafficked liveblog, Fastly is pretty important. You'll also need to set up your DNS to use a DNS to CDN to Origin configuration with Fastly. [This blog post](https://robots.thoughtbot.com/dns-cdn-origin) explains the basics very well.

### Set up integrations on Slack

#### Create your slash commands

Create two new [Slack slash commands](https://slack.com/services/new/slash-commands) with the following configuration:

**Command:** /start_liveblog
**URL:** http://<your_url>/incoming

**Command:** /end_liveblog
**URL:** http://<your_url>/incoming

You'll need to copy the Token for each of these slash commands to use when configuring Heroku below.

#### Create your Outgoing webhook integration

Create a new [Outgoing webhook](https://slack.com/services/new/outgoing-webhook) integration. This will allow you to watch a specific room where liveblogs will be taking place for all messages.

When you're configuring this integration, set the channel to the channel where your liveblogs will be taking place, and set the url to http://<your_url>/incoming.

Again, copy the token for use configuring Heroku below.

### Heroku deploy

```bash
# clone repository
git clone git@github.com:adampash/slack-liveblog.git
cd slack-liveblog

# create heroku app
heroku apps:create [NAME]
heroku git:remote -a [NAME]

# deploy to heroku
git push heroku

# Heroku add-ons I'm using
heroku addons:create heroku-postgresql:standard-0
heroku addons:create memcachier:100
heroku addons:create newrelic:wayne
heroku addons:create rediscloud:30
heroku addons:create rollbar:free


# Set config variables
# AWS keys
heroku config:add AWS_ACCESS_KEY=<KEY>
heroku config:add AWS_BUCKET=<KEY>
heroku config:add AWS_SECRET_ACCESS_KEY=<KEY>
heroku config:add AWS_SECRET_KEY=<KEY>

# Fastly keys
heroku config:add FASTLY_API_KEY=<KEY>
heroku config:add FASTLY_SERVICE_ID=<KEY>
heroku config:add FOG_DIRECTORY=<KEY>
heroku config:add FOG_PROVIDER=<KEY>

# Config
heroku config:add MAX_THREADS=3
heroku config:add WEB_CONCURRENCY=3
heroku config:add REDIS_PROVIDER=REDISCLOUD_URL

# Slack keys
heroku config:add SLACK_API_TOKEN=[key] # Used to configure SlackClient; go to https://api.slack.com/web to get this token
heroku config:add SLACK_START_TOKEN=[key] # This token will be available when you set up your /start_liveblog slash command

heroku config:add SLACK_END_TOKEN=[key] # This token will be available when you set up your /end_liveblog slash command
heroku config:add SLACK_OUTGOING_TOKEN=[key] # This token will be available when you set up your Outgoing webhooks integration
```
