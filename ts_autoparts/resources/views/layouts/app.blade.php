<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel</title>

    <!-- Tailwind CSS (CDN) -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome (CDN) for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet">

    <style>
        /* Custom styles for the sidebar */
        .sidebar {
            height: 100%;
            position: fixed;
            top: 0;
            left: 0;
            width: 250px;
            background-color: #144FAB;
            padding-top: 20px;
            z-index: 1000;
        }

        .sidebar a {
            color: white;
            padding: 15px;
            text-decoration: none;
            font-size: 18px;
            display: block;
            padding-left: 25px;
        }

        .sidebar a:hover {
            background-color: rgb(155, 157, 206);
        }

        .logo {
            display: block;
            margin: 0 auto;
            width: 50%;
            padding-bottom: 20px;
        }

        /* Content area */
        .content-area {
            margin-left: 260px;
            padding: 20px;
        }

        /* Sidebar Icon Styling */
        .sidebar i {
            margin-right: 10px;
        }

        /* Logout Button */
        .logout-btn {
            position: absolute;
            bottom: 20px;
            left: 0;
            width: 100%;
        }

        .logout-btn form {
            margin: 0;
        }

        .logout-btn button {
            width: 100%;
            background: none;
            color: white;
            padding: 15px;
            font-size: 18px;
            border: none;
            cursor: pointer;
            text-align: left;
            padding-left: 25px;
        }

        .logout-btn button:hover {
            background-color: rgb(155, 157, 206);
        }
    </style>
</head>

<body class="bg-gray-100">

    <!-- Sidebar -->
    <div class="sidebar bg-blue-800">
        <!-- Logo -->
        <img src="{{ asset('images/logo.svg') }}" alt="Admin Logo" class="logo">

        <a href="{{ route('admin.dashboard') }}" class="flex items-center py-3 px-4 text-white hover:bg-blue-700">
            <i class="fas fa-tachometer-alt mr-3"></i> Dashboard
        </a>
        <a href="{{ route('admin.orders') }}" class="flex items-center py-3 px-4 text-white hover:bg-blue-700">
            <i class="fas fa-box mr-3"></i> Orders
        </a>
        <a href="{{ route('admin.appointments') }}" class="flex items-center py-3 px-4 text-white hover:bg-blue-700">
            <i class="fas fa-calendar-check mr-3"></i> Appointments
        </a>
        <a href="{{ route('admin.products.index') }}" class="flex items-center py-3 px-4 text-white hover:bg-blue-700">
            <i class="fas fa-cogs mr-3"></i> Products
        </a>
        <a href="{{ route('admin.users.index') }}" class="flex items-center py-3 px-4 text-white hover:bg-blue-700">
            <i class="fas fa-users mr-3"></i> Users
        </a>

        <!-- Categories link -->
        <a href="{{ route('admin.categories.index') }}" class="flex items-center py-3 px-4 text-white hover:bg-blue-700">
            <i class="fas fa-th-list mr-3"></i> Categories
        </a>

        <!-- Logout Button -->
        <div class="logout-btn">
            <form action="{{ route('admin.logout') }}" method="POST">
                @csrf
                <button type="submit" class="flex items-center py-3 px-4 text-white hover:bg-blue-700">
                    <i class="fas fa-sign-out-alt mr-3"></i> Logout
                </button>
            </form>
        </div>
    </div>

    <!-- Main Content Area -->
    <div class="content-area ml-[260px] p-6">
        @yield('content') <!-- This is where the content of the dashboard will be inserted -->
    </div>

    <!-- Tailwind JS (optional for dynamic components) -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js"></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

</body>

</html>
