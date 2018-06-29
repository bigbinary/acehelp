# AceHelp

[AceHelp](https://www.acehelp.com) makes online help docs contextual.

## Install dependencies

- Ruby(2.5.1)
- Rails(5.2.0)
- node(8+)
- PostgreSQL(9+)
- ElasticSearch(`brew install elasticsearch`)


## Local Development setup

```
./bin/bundle install

# Database setup and populate sample data
cp config/database.yml.postgresql config/database.yml

./bin/rails db:setup

./bin/yarn install

npm install -g elm

elm-package install

foreman start -f Procfile.dev
```

Once we see `webpack: Compiled successfully.` message in terminal,
we can visit the app at http://localhost:3000.

To create data e.g. Article, URLs etc. you must login as a user.
To login as a user, please visit http://localhost:3000/users/sign_in

```
# Login info
sam@example.com / welcome
```

Webpack will automatically compile if a file inside `app/javascript/` directory is modified in development mode.

## GraphQL is enabled
Once servers are up and running, visit `localhost:3000/graphql/playground` to play around GraphQL queries and mutations.

## Heroku Review

[Heroku Review](https://devcenter.heroku.com/articles/github-integration-review-apps)
is enabled on this application. It means when a PR is sent then Heroku
automatically deploys an application for that branch.

## Continuous deployment when PR is merged to master

Whenever PR is merged to master then master code is automatically deployed to [http://staging.acehelp.com](http://staging.acehelp.com).

## About BigBinary

![BigBinary](https://raw.githubusercontent.com/bigbinary/bigbinary-assets/press-assets/PNG/logo-light-solid-small.png?raw=true)

AceHelp is maintained by [BigBinary](https://www.BigBinary.com). BigBinary is a software consultancy company. We build web and mobile applications using Ruby on Rails, React.js, React Native and Elm.
