0;115;0c# Welcome to Geek Jeopardy

Geek Jeopardy is

## Setup

Install dependencies

    bundle install

## Usage

Start the server

    MASTER_PASSWORD=secret bundle exec rackup -E production

Browse to

    http://localhost:9292/master

The login is `geek` the password is the one you set before.

The current URL will be used to display the URL for the participants.
So if running this on you machine, you will want to lookup the current
IP address of your machine and use that one instead.

    hostname -I | cut -d ' ' -f 1

## References

* https://github.com/jakesgordon/javascript-state-machine
