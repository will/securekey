# SecureKey

Automatic and graceful secure key rotation as a service (AaGSKRaaS)

## Usage

    $ heroku addons:add securekey
    -----> Adding securekey to will... done, v216 (free)

    $ heroku config -s | grep SECURE_KEYS
    SECURE_KEYS=59b26bion3ow0o46hkw8laij99sm4gxe766q5iztumy7pz6o2m,omhltkx5cucsj9wbxw5j486uwoka3ckkjznk6fpowwywlblu6

    ...time passes...

    $ heroku config -s | grep SECURE_KEYS
    SECURE_KEYS=4pndhwz8dk57la2fqz0rdakseofsnzqbuz8a0vcwirjkpypcb7,59b26bion3ow0o46hkw8laij99sm4gxe766q5iztumy7pz6o2m

    ...time passes...

    $ heroku config -s | grep SECURE_KEYS
    SECURE_KEYS=5xhuqknssevprev03qivap4d4se4dx5xardk95y6enz7uru7eo,4pndhwz8dk57la2fqz0rdakseofsnzqbuz8a0vcwirjkpypcb7

## Why?

Because you're not rotating your keys at all. And they're probably checked
into your repo, which is bad. Add this add-on, and never think about it again.

You need to keep and accept the old key for a while, or your users will lose
their sessions right away. My [patch to Rack::Cookie](https://github.com/rack/rack/pull/263)
takes care of that for you. A rails patch is coming soon.

## Install

Clone then run:

    $ bundle install

Next you'll want to make sure you've got a local database set up:


Then you can create and migrate your database by running:

    $ createdb secure_key
    $ sequel -m db/ postgres:///secure_key


Make sure tests pass by running:

    $ bundle exec rake

## A Heroku add-on, running on Heroku, made with Heroku add-ons

It currently uses the free heroku-postgres dev plan, pgbackups, and scheduler add-ons.
The code is over at [github.com/will/securekey](http://github.com/will/securekey).

