# SecureKey

Automatic and graceful secure key rotation as a service (AaGSKRaaS)

## Usage

    $ heroku addons:add securekey
    -----> Adding securekey to will... done, v216 (free)

    $ heroku config -s | grep SECURE_KEY
    SECURE_KEY=59b26bion3ow0o46hkw8laij99sm4gxe766q5iztumy7pz6o2m
    SECURE_KEY_OLD=omhltkx5cucsj9wbxw5j486uwoka3ckkjznk6fpowwywlblu6

    ...time passes...

    $ heroku config -s | grep SECURE_KEY
    SECURE_KEY=4pndhwz8dk57la2fqz0rdakseofsnzqbuz8a0vcwirjkpypcb7
    SECURE_KEY_OLD=59b26bion3ow0o46hkw8laij99sm4gxe766q5iztumy7pz6o2m

    ...time passes...

    $ heroku config -s | grep SECURE_KEY
    SECURE_KEY=5xhuqknssevprev03qivap4d4se4dx5xardk95y6enz7uru7eo
    SECURE_KEY_OLD=4pndhwz8dk57la2fqz0rdakseofsnzqbuz8a0vcwirjkpypcb7

## Why?

Because you're not rotating your keys at all. And they're probably checked 
into your repo, which is bad. Add this addon, and never think about it again.

You need to keep and accept the old key for a while, or your users will lose
their sessions right away. My [patch to Rack::Cookie](https://github.com/rack/rack/pull/263)
takes care of that for you

