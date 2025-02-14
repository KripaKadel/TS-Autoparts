<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>

    <!-- Bootstrap CSS (CDN) -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS for dashboard -->
    <style>
        .sidebar {
            height: 100%;
            position: fixed;
            top: 0;
            left: 0;
            width: 250px;
            background-color: #343a40;
            padding-top: 20px;
        }

        .sidebar a {
            color: white;
            padding: 15px;
            text-decoration: none;
            font-size: 18px;
            display: block;
        }

        .sidebar a:hover {
            background-color: #575757;
        }

        .content {
            margin-left: 250px;
            padding: 20px;
        }

        .card-title {
            font-size: 24px;
            font-weight: bold;
        }

        .card {
            margin-bottom: 20px;
        }

        .card-body {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .dashboard-link {
            text-decoration: none;
            color: #007bff;
            font-size: 18px;
        }

        .dashboard-link:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>

    <!-- Sidebar -->
    <div class="sidebar">
        <h3 class="text-white text-center">Admin Panel</h3>
        <a href="#">Dashboard</a>
        <a href="{{ route('admin.orders') }}">Manage Orders</a>
        <a href="{{ route('admin.appointments') }}">Manage Appointments</a>
        <a href="{{ route('admin.products') }}">Manage Products</a>
        <a href="{{ route('admin.users') }}">Manage Users</a>
    </div>

    <!-- Main Content -->
    <div class="content">
        <!-- Navbar -->
        <nav class="navbar navbar-expand-lg navbar-light bg-light">
            <a class="navbar-brand" href="#">Admin Dashboard</a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav"
                aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ml-auto">
                    <li class="nav-item active">
                        <a class="nav-link" href="#">Hello, Admin</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="{{ route('admin.logout') }}">Logout</a>
                    </li>
                </ul>
            </div>
        </nav>

        <!-- Welcome Message and Dashboard Stats -->
        <div class="container-fluid mt-4">
            <div class="row">
                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div>
                                <h5 class="card-title">Total Orders</h5>
                                <p class="card-text">25</p>
                            </div>
                            <a href="{{ route('admin.orders') }}" class="dashboard-link">Manage Orders</a>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div>
                                <h5 class="card-title">Total Appointments</h5>
                                <p class="card-text">15</p>
                            </div>
                            <a href="{{ route('admin.appointments') }}" class="dashboard-link">Manage Appointments</a>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div>
                                <h5 class="card-title">Total Products</h5>
                                <p class="card-text">30</p>
                            </div>
                            <a href="{{ route('admin.products') }}" class="dashboard-link">Manage Products</a>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card">
                        <div class="card-body">
                            <div>
                                <h5 class="card-title">Total Users</h5>
                                <p class="card-text">100</p>
                            </div>
                            <a href="{{ route('admin.users') }}" class="dashboard-link">Manage Users</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS and dependencies (CDN) -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>

</html>
