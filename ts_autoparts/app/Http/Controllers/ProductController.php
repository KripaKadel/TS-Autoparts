<?php

namespace App\Http\Controllers;

use App\Models\Products;
use App\Models\Categories;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    // Display a list of all products
    public function index()
    {
        $products = Products::all();
        return view('admin.products.index', compact('products'));
    }

    // Show the form to create a new product
    public function create()
    {
        $categories = Categories::all(); // Get all categories to select
        return view('admin.products.create', compact('categories'));
    }

    // Store a new product in the database
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
            $imagePath = $request->file('image')->store('product_images', 'public');
        }

        // Store the product in the database
        Products::create([
            'name' => $request->name,
            'brand' => $request->brand,
            'category_id' => $request->category_id,
            'price' => $request->price,
            'model' => $request->model,
            'stock' => $request->stock,
            'description' => $request->description,
            'image' => $imagePath,
        ]);

        return redirect()->route('admin.products.index')->with('success', 'Product created successfully.');
    }

    // Show the form for editing an existing product
    public function edit($id)
    {
        $product = Products::findOrFail($id);
        $categories = Categories::all(); // Get all categories for selection
        return view('admin.products.edit', compact('product', 'categories'));
    }

    // Update an existing product
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
            $imagePath = $request->file('image')->store('product_images', 'public');
        } else {
            // If no new image is uploaded, retain the old image
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

        // Redirect back to the index page with a success message
        return redirect()->route('admin.products.index')->with('success', 'Product updated successfully.');
    }

    // Delete a product
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

        // Redirect to the index page with a success message
        return redirect()->route('admin.products.index')->with('success', 'Product deleted successfully.');
    }
}
