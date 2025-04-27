@extends('layouts.app')

@section('title', 'Generate Reports')

@section('content')
<div class="bg-gray-50 min-h-screen">
    <div class="max-w-7xl mx-auto px-6 py-8">
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="px-5 py-4 border-b border-gray-100">
                <h1 class="text-2xl font-bold text-gray-900">Generate Reports</h1>
                <p class="mt-2 text-gray-600">Select the type of report and date range to generate.</p>
            </div>

            <div class="p-6">
                <form id="reportForm" class="space-y-6">
                    @csrf
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Report Type -->
                        <div>
                            <label for="report_type" class="block text-sm font-medium text-gray-700">Report Type</label>
                            <select id="report_type" name="report_type" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
                                <option value="sales">Sales Report</option>
                                <option value="orders">Orders Report</option>
                                <option value="appointments">Appointments Report</option>
                                <option value="products">Products Report</option>
                            </select>
                        </div>

                        <!-- Date Range -->
                        <div>
                            <label for="date_range" class="block text-sm font-medium text-gray-700">Date Range</label>
                            <div class="mt-1 flex space-x-4">
                                <input type="date" id="start_date" name="start_date" class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" required>
                                <input type="date" id="end_date" name="end_date" class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" required>
                            </div>
                            <div class="text-red-500 text-sm mt-2" id="dateError"></div> <!-- Error Message -->
                        </div>

                        <!-- Format -->
                        <div>
                            <label for="format" class="block text-sm font-medium text-gray-700">Format</label>
                            <select id="format" name="format" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500">
                                <option value="pdf">PDF</option>
                                <option value="csv">CSV</option>
                            </select>
                        </div>
                    </div>

                    <!-- Chart Preview -->
                    <div id="chartPreview" class="mt-8">
                        <canvas id="chartCanvas"></canvas> <!-- Chart.js Canvas -->
                    </div>

                    <div class="flex justify-end">
                        <button type="submit" class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                                <polyline points="7 10 12 15 17 10"/>
                                <line x1="12" y1="15" x2="12" y2="3"/>
                            </svg>
                            Generate Report
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script> <!-- Chart.js CDN -->

<script>
document.getElementById('reportForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const startDate = document.getElementById('start_date').value;
    const endDate = document.getElementById('end_date').value;

    // Validate Date Range
    if (!startDate || !endDate) {
        document.getElementById('dateError').innerText = "Please select a valid date range.";
        return;
    }

    // Remove previous error message if any
    document.getElementById('dateError').innerText = '';

    const formData = new FormData(this);
    const queryString = new URLSearchParams(formData).toString();

    // Fetch chart data for preview before generating the report
    fetch('{{ route("admin.reports.chartData") }}?' + queryString)
        .then(response => response.json())
        .then(data => {
            // Update chart with new data
            const ctx = document.getElementById('chartCanvas').getContext('2d');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.labels,  // Example: ['Jan', 'Feb', 'Mar', ...]
                    datasets: [{
                        label: 'Amount',
                        data: data.values,  // Example: [10, 20, 30, ...]
                        backgroundColor: 'rgba(75, 192, 192, 0.2)',
                        borderColor: 'rgba(75, 192, 192, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        })
        .catch(error => {
            console.error('Error fetching chart data:', error);
            alert('Failed to fetch chart data.');
        });

    // Create a hidden form for proper file download
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '{{ route("admin.reports.generate") }}';
    
    // Add CSRF token
    const csrfInput = document.createElement('input');
    csrfInput.type = 'hidden';
    csrfInput.name = '_token';
    csrfInput.value = '{{ csrf_token() }}';
    form.appendChild(csrfInput);
    
    // Add form data
    for (let pair of formData.entries()) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = pair[0];
        input.value = pair[1];
        form.appendChild(input);
    }
    
    document.body.appendChild(form);
    form.submit();
    document.body.removeChild(form);
});
</script>
@endsection
