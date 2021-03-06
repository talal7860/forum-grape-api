[![CircleCI](https://circleci.com/gh/talal7860/forum-grape-api.svg?style=svg)](https://circleci.com/gh/talal7860/forum-grape-api)
[![Build Status](https://travis-ci.org/talal7860/forum-grape-api.svg?branch=develop)](https://travis-ci.org/talal7860/forum-grape-api)
[![Coverage Status](https://coveralls.io/repos/github/talal7860/forum-grape-api/badge.svg?branch=develop)](https://coveralls.io/github/talal7860/forum-grape-api?branch=develop)
[![Maintainability](https://api.codeclimate.com/v1/badges/41bb74786bee25a492c5/maintainability)](https://codeclimate.com/github/talal7860/forum-grape-api/maintainability)

# Forum Api in Rails + Grape

This rails app is an example of rest api built using [Grape](https://github.com/ruby-grape/grape)

## Setup
- `git clone https://github.com/talal7860/forum-grape-api`
- `bundle install`
- `rake db:create`
- `rake db:setup`
- To add dummy data run this rake command: `rake forum_api:create_dummy_data`

## End Points
- Run the server and all the end points can be viewed and test on [Swagger Documentation](http://localhost:3000/docs/index.html)

## Front End App
- The sample Front end App using ReactJS can be found here: [Forum React App](https://github.com/talal7860/forum-react-app)
