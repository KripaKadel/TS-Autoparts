<?php

return [

    /*
    |---------------------------------------------------------------------------
    | Authentication Defaults
    |---------------------------------------------------------------------------
    |
    | This option controls the default authentication "guard" and password
    | reset options for your application. You may change these defaults
    | as required, but they're a perfect start for most applications.
    |
    */

    'defaults' => [
        'guard' => 'web',  // Default to 'web' guard for session-based auth
        'passwords' => 'users',
    ],

    /*
    |---------------------------------------------------------------------------
    | Authentication Guards
    |---------------------------------------------------------------------------
    |
    | Here you may define every authentication guard for your application.
    | The "web" guard is used for session-based authentication, while the
    | "api" guard is used for token-based authentication (Sanctum in this case).
    |
    */

    'guards' => [
        'web' => [
            'driver' => 'session',  // For web-based session auth
            'provider' => 'users',
        ],

        'api' => [
            'driver' => 'sanctum',  // Use Sanctum for API authentication
            'provider' => 'users',
        ],
    ],

    /*
    |---------------------------------------------------------------------------
    | User Providers
    |---------------------------------------------------------------------------
    |
    | User providers define how the users are retrieved from your database.
    | By default, it uses Eloquent, but you can configure it to use the database
    | if needed.
    |
    */

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class,
        ],
    ],

    /*
    |---------------------------------------------------------------------------
    | Resetting Passwords
    |---------------------------------------------------------------------------
    |
    | You may specify multiple password reset configurations for various user
    | tables/models. Here, we're defining the password reset settings for the
    | 'users' provider.
    |
    */

    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => 'password_resets',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    /*
    |---------------------------------------------------------------------------
    | Password Confirmation Timeout
    |---------------------------------------------------------------------------
    |
    | This option specifies how long the password confirmation should last.
    | By default, it is 3 hours.
    |
    */

    'password_timeout' => 10800,
];
