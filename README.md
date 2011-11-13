## SecureKey

Automatic and graceful secure key rotation as a service (AaGSKRaaS)

    $ heroku addons:add securekey
    -----> Adding securekey to will... done, v216 (free)

    $ heroku config -s | grep SECURE_KEY
    SECURE_KEY=59b26bion3ow0o46hkw8laij99sm4gxe766q5iztumy7pz6o2m
    SECURE_KEY_OLD=

    ...time passes...

    $ heroku config -s | grep SECURE_KEY
    SECURE_KEY=4pndhwz8dk57la2fqz0rdakseofsnzqbuz8a0vcwirjkpypcb7
    SECURE_KEY_OLD=59b26bion3ow0o46hkw8laij99sm4gxe766q5iztumy7pz6o2m

    ...time passes...

    $ heroku config -s | grep SECURE_KEY
    SECURE_KEY=5xhuqknssevprev03qivap4d4se4dx5xardk95y6enz7uru7eo
    SECURE_KEY_OLD=4pndhwz8dk57la2fqz0rdakseofsnzqbuz8a0vcwirjkpypcb7
