<?php

namespace App\Http\Controllers;

use App\Models\Categories;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    // Show the list of categories
    public function index()
    {
        // Fetch all categories from the database
        $categories = Categories::all();

        // Return a view and pass the categories to it
        return view('admin.categories.index', compact('categories'));
    }

    // Show the form to create a new category
    public function create()
    {
        return view('admin.categories.create');
    }

    // Store a newly created category in the database
    public function store(Request $request)
    {
        // Validate the incoming data
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
        ]);

        // Create a new category
        Categories::create([
            'name' => $request->name,
            'description' => $request->description,
        ]);

        // Redirect to a category list or success page
        return redirect()->route('admin.categories.index')->with('success', 'Category created successfully!');
    }

    // Show the form to edit an existing category
    public function edit($id)
    {
        // Find the category by its ID
        $category = Categories::findOrFail($id);

        // Return the edit view and pass the category to it
        return view('admin.categories.edit', compact('category'));
    }

    // Update the category in the database
    public function update(Request $request, $id)
    {
        // Find the category by its ID
        $category = Categories::findOrFail($id);

        // Validate the incoming data
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
        ]);

        // Update the category with the validated data
        $category->update([
            'name' => $request->name,
            'description' => $request->description,
        ]);

        // Redirect back to the edit page with a success message
        return redirect()->route('admin.categories.index', $category->id)
                         ->with('success', 'Category updated successfully!');
    }

    // Delete a category from the database
    public function destroy($id)
    {
        // Find the category by its ID
        $category = Categories::findOrFail($id);

        // Delete the category
        $category->delete();

        // Redirect to the category list with a success message
        return redirect()->route('admin.categories.index')->with('success', 'Category deleted successfully!');
    }
}
