<?php

return [
    'secret_key' => env('8e864bdb3c7046589c9a2470a186ddd8'),
    'public_key' => env('e3ae01975125486f96a9b3e8e29077e2'),
    'app_url' => env('http://localhost:8000'),
    'api_url' => env('KHALTI_API_URL', 'https://khalti.com/api/v2'),
    'verification_url' => env('KHALTI_API_URL', 'https://khalti.com/api/v2') . '/payment/verify/',
    'epayment_url' => env('KHALTI_API_URL', 'https://khalti.com/api/v2') . '/epayment/initiate/',
];