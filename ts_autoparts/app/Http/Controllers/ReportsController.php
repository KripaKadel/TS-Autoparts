<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Appointment;
use App\Models\Payments;
use App\Models\Products;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Barryvdh\DomPDF\Facade\Pdf;

class ReportsController extends Controller
{
    public function index()
    {
        return view('admin.reports.index');
    }

    public function getChartData(Request $request)
    {
        $request->validate([
            'report_type' => 'required|in:sales,orders,appointments,products',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        $startDate = Carbon::parse($request->start_date);
        $endDate = Carbon::parse($request->end_date);

        $labels = [];
        $values = [];

        switch ($request->report_type) {
            case 'sales':
                $data = Payments::whereBetween('created_at', [$startDate, $endDate])
                    ->where('status', 'success')
                    ->get();
                $labels = $data->groupBy(function ($item) {
                    return $item->created_at->format('Y-m-d');
                });
                $values = $labels->map(function ($day) {
                    return $day->sum('amount');
                });
                break;
            case 'orders':
                $data = Order::whereBetween('created_at', [$startDate, $endDate])
                    ->with(['user'])
                    ->get();
                $labels = $data->groupBy(function ($item) {
                    return $item->created_at->format('Y-m-d');
                });
                $values = $labels->map(function ($day) {
                    return $day->sum('total_amount');
                });
                break;
            case 'appointments':
                $data = Appointment::whereBetween('created_at', [$startDate, $endDate])
                    ->with(['user'])
                    ->get();
                $labels = $data->groupBy(function ($item) {
                    return $item->created_at->format('Y-m-d');
                });
                $values = $labels->map(function ($day) {
                    return $day->count();
                });
                break;
            case 'products':
                $data = Products::whereBetween('created_at', [$startDate, $endDate])
                    ->get();
                $labels = $data->groupBy(function ($item) {
                    return $item->created_at->format('Y-m-d');
                });
                $values = $labels->map(function ($day) {
                    return $day->count();
                });
                break;
            default:
                return response()->json(['error' => 'Invalid report type'], 400);
        }

        return response()->json([
            'labels' => $labels->keys(),
            'values' => $values->values(),
        ]);
    }

    public function generateReport(Request $request)
    {
        $request->validate([
            'report_type' => 'required|in:sales,orders,appointments,products',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'format' => 'required|in:pdf,csv'
        ]);

        $startDate = Carbon::parse($request->start_date);
        $endDate = Carbon::parse($request->end_date);

        switch ($request->report_type) {
            case 'sales':
                $data = Payments::whereBetween('created_at', [$startDate, $endDate])
                    ->where('status', 'success')
                    ->get();
                $filename = 'sales_report';
                break;
            case 'orders':
                $data = Order::whereBetween('created_at', [$startDate, $endDate])
                    ->with(['user', 'orderItems'])
                    ->get();
                $filename = 'orders_report';
                break;
            case 'appointments':
                $data = Appointment::whereBetween('created_at', [$startDate, $endDate])
                    ->with(['user'])
                    ->get();
                $filename = 'appointments_report';
                break;
            case 'products':
                $data = Products::whereBetween('created_at', [$startDate, $endDate])
                    ->get();
                $filename = 'products_report';
                break;
        }

        if ($request->format === 'pdf') {
            $pdf = PDF::loadView('admin.reports.pdf', [
                'data' => $data,
                'type' => $request->report_type,
                'startDate' => $startDate->format('Y-m-d'),
                'endDate' => $endDate->format('Y-m-d')
            ]);
            
            return $pdf->download($filename . '.pdf');
        } else {
            $headers = [
                'Content-Type' => 'text/csv',
                'Content-Disposition' => 'attachment; filename="' . $filename . '.csv"',
                'Pragma' => 'no-cache',
                'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
                'Expires' => '0'
            ];

            $callback = function() use($data, $request) {
                $handle = fopen('php://output', 'w');
                
                // Write headers based on report type
                switch ($request->report_type) {
                    case 'sales':
                        fputcsv($handle, ['ID', 'Amount', 'Status', 'Date']);
                        foreach ($data as $item) {
                            fputcsv($handle, [
                                $item->id,
                                $item->amount,
                                $item->status,
                                $item->created_at
                            ]);
                        }
                        break;
                    case 'orders':
                        fputcsv($handle, ['ID', 'Customer', 'Total Amount', 'Status', 'Date']);
                        foreach ($data as $item) {
                            fputcsv($handle, [
                                $item->id,
                                $item->user->name,
                                $item->total_amount,
                                $item->status,
                                $item->created_at
                            ]);
                        }
                        break;
                    case 'appointments':
                        fputcsv($handle, ['ID', 'Customer', 'Date', 'Time', 'Status']);
                        foreach ($data as $item) {
                            fputcsv($handle, [
                                $item->id,
                                $item->user->name,
                                $item->date,
                                $item->time,
                                $item->status
                            ]);
                        }
                        break;
                    case 'products':
                        fputcsv($handle, ['ID', 'Name', 'Price', 'Stock', 'Created At']);
                        foreach ($data as $item) {
                            fputcsv($handle, [
                                $item->id,
                                $item->name,
                                $item->price,
                                $item->stock,
                                $item->created_at
                            ]);
                        }
                        break;
                }
                
                fclose($handle);
            };

            return response()->stream($callback, 200, $headers);
        }
        
    }
}
