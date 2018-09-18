# AceHelp

[AceHelp](https://www.acehelp.com) makes online help docs contextual.

## Install dependencies

- node(8+)

## Local Development setup

```
./bin/setup
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

Visit https://github.com/bigbinary/acehelp/tree/master/docs/graphql-examples
to see some examples of how to use GraphQL.

## Heroku Review

[Heroku Review](https://devcenter.heroku.com/articles/github-integration-review-apps)
is enabled on this application. It means when a PR is sent then Heroku
automatically deploys an application for that branch.

## Continuous deployment when PR is merged to master

Whenever PR is merged to master then master code is automatically deployed to [http://staging.acehelp.com](http://staging.acehelp.com).

## Working example
Visit the following link to view AceHelp in action
[https://careforever-for-acehelp.herokuapp.com/](https://careforever-for-acehelp.herokuapp.com/)

## About BigBinary

![BigBinary](https://raw.githubusercontent.com/bigbinary/bigbinary-assets/press-assets/PNG/logo-light-solid-small.png?raw=true)

AceHelp is maintained by [BigBinary](https://www.BigBinary.com). BigBinary is a software consultancy company. We build web and mobile applications using Ruby on Rails, React.js, React Native and Elm.
