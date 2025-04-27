<?php

namespace App\Http\Controllers;

use App\Models\Products;
use App\Models\Categories;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class ProductController extends Controller
{
    // Display a list of all products (Admin Panel)
    public function index(Request $request)
{
    // Start with the base query
    $productsQuery = Products::with('category');
    
    // Apply search filter if provided
    if ($request->filled('search')) {
        $search = $request->input('search');
        $productsQuery->where(function($query) use ($search) {
            $query->where('name', 'like', "%$search%")
                  ->orWhere('brand', 'like', "%$search%")
                  ->orWhere('model', 'like', "%$search%")
                  ->orWhere('description', 'like', "%$search%");
        });
    }
    
    // Apply brand filter if provided
    if ($request->filled('brand')) {
        $productsQuery->where('brand', $request->input('brand'));
    }
    
    // Apply category filter if provided
    if ($request->filled('category')) {
        $productsQuery->where('category_id', $request->input('category'));
    }
    
    // Get all distinct brands for the filter dropdown
    $brands = Products::select('brand')->distinct()->orderBy('brand')->pluck('brand');
    
    // Get all categories for the filter dropdown
    $categories = Categories::orderBy('name')->get();
    
    // Paginate the results
    $products = $productsQuery->paginate(15)->appends($request->query());
    
    return view('admin.products.index', compact('products', 'brands', 'categories'));
}

    // API Version: Display a list of all products
    public function apiIndex()
    {
        // Fetch all products with categories (For API Response)
        $products = Products::with('category')->get();

        // Return the products with the full image URL as a JSON response
        return response()->json($products);
    }

    // Show the form to create a new product (Admin Panel)
    public function create()
    {
        // Get all categories for selection in the form
        $categories = Categories::all();
        return view('admin.products.create', compact('categories'));
    }

    // Store a new product in the database (Admin Panel)
    public function store(Request $request)
    {
        // Validate input data
        $request->validate([
            'name' => 'required|string|max:255',
            'brand' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'price' => 'required|numeric',
            'model' => 'required|string|max:255',
            'stock' => 'required|integer',
            'description' => 'required|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        // Handle image upload if provided
        $imagePath = null;
        if ($request->hasFile('image')) {
            // Generate a custom file name based on product name
            $imageName = Str::slug($request->name) . '.' . $request->file('image')->getClientOriginalExtension();
            
            // Store the image with the custom name in the 'product_images' directory
            $imagePath = $request->file('image')->storeAs('product_images', $imageName, 'public');
        }

        // Store the product in the database
        $product = Products::create([
            'name' => $request->name,
            'brand' => $request->brand,
            'category_id' => $request->category_id,
            'price' => $request->price,
            'model' => $request->model,
            'stock' => $request->stock,
            'description' => $request->description,
            'image' => $imagePath,
        ]);

        // Redirect with success message
        return redirect()->route('admin.products.index')->with('success', 'Product created successfully.');
    }

    // Show the form for editing an existing product (Admin Panel)
    public function edit($id)
    {
        // Fetch the product and categories for selection
        $product = Products::findOrFail($id);
        $categories = Categories::all();
        return view('admin.products.edit', compact('product', 'categories'));
    }

    // Update an existing product (Admin Panel)
    public function update(Request $request, $id)
    {
        // Validate input data
        $request->validate([
            'name' => 'required|string|max:255',
            'brand' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'price' => 'required|numeric',
            'model' => 'required|string|max:255',
            'stock' => 'required|integer',
            'description' => 'required|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        // Find the product by id
        $product = Products::findOrFail($id);

        // Handle image upload if provided
        if ($request->hasFile('image')) {
            // Delete old image if it exists
            if ($product->image) {
                Storage::delete('public/' . $product->image);
            }

            // Generate a custom file name based on product name
            $imageName = Str::slug($request->name) . '.' . $request->file('image')->getClientOriginalExtension();

            // Store the image with the custom name in the 'product_images' directory
            $imagePath = $request->file('image')->storeAs('product_images', $imageName, 'public');
        } else {
            // Retain old image if no new image is uploaded
            $imagePath = $product->image;
        }

        // Update the product in the database
        $product->update([
            'name' => $request->name,
            'brand' => $request->brand,
            'category_id' => $request->category_id,
            'price' => $request->price,
            'model' => $request->model,
            'stock' => $request->stock,
            'description' => $request->description,
            'image' => $imagePath,
        ]);

        // Redirect with success message
        return redirect()->route('admin.products.index')->with('success', 'Product updated successfully.');
    }

    // Delete a product (Admin Panel)
    public function destroy($id)
    {
        // Find the product by id
        $product = Products::findOrFail($id);

        // Delete product image if it exists
        if ($product->image) {
            Storage::delete('public/' . $product->image);
        }

        // Delete the product
        $product->delete();

        // Redirect with success message
        return redirect()->route('admin.products.index')->with('success', 'Product deleted successfully.');
    }
}