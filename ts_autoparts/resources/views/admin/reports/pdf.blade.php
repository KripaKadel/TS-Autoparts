<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>{{ ucfirst($type) }} Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        .date-range {
            text-align: center;
            margin-bottom: 20px;
            color: #666;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f5f5f5;
        }
        .total {
            margin-top: 20px;
            text-align: right;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{ ucfirst($type) }} Report</h1>
        <div class="date-range">
            From {{ $startDate }} to {{ $endDate }}
        </div>
    </div>

    <table>
        <thead>
            @switch($type)
                @case('sales')
                    <tr>
                        <th>ID</th>
                        <th>Amount</th>
                        <th>Status</th>
                        <th>Date</th>
                    </tr>
                    @break
                @case('orders')
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Total Amount</th>
                        <th>Status</th>
                        <th>Date</th>
                    </tr>
                    @break
                @case('appointments')
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Status</th>
                    </tr>
                    @break
                @case('products')
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Created At</th>
                    </tr>
                    @break
            @endswitch
        </thead>
        <tbody>
            @foreach($data as $item)
                <tr>
                    @switch($type)
                        @case('sales')
                            <td>{{ $item->id }}</td>
                            <td>{{ $item->amount }}</td>
                            <td>{{ $item->status }}</td>
                            <td>{{ $item->created_at }}</td>
                            @break
                        @case('orders')
                            <td>{{ $item->id }}</td>
                            <td>{{ $item->user->name }}</td>
                            <td>{{ $item->total_amount }}</td>
                            <td>{{ $item->status }}</td>
                            <td>{{ $item->created_at }}</td>
                            @break
                        @case('appointments')
                            <td>{{ $item->id }}</td>
                            <td>{{ $item->user->name }}</td>
                            <td>{{ $item->date }}</td>
                            <td>{{ $item->time }}</td>
                            <td>{{ $item->status }}</td>
                            @break
                        @case('products')
                            <td>{{ $item->id }}</td>
                            <td>{{ $item->name }}</td>
                            <td>{{ $item->price }}</td>
                            <td>{{ $item->stock }}</td>
                            <td>{{ $item->created_at }}</td>
                            @break
                    @endswitch
                </tr>
            @endforeach
        </tbody>
    </table>

    @if($type === 'sales')
        <div class="total">
            Total Sales: {{ $data->sum('amount') }}
        </div>
    @elseif($type === 'orders')
        <div class="total">
            Total Orders: {{ $data->count() }}
        </div>
    @endif
</body>
</html> 