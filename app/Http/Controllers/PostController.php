<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PostController extends Controller
{
    public function index() {
        return response()->json(
            Post::all()
        );
    }

    public function view($id) {
        return response()->json(
            Post::find($id)
        );
    }

    public function create(Request $request) {
        return response()->json(
            Post::create($request->all())
        );
    }

    public function delete($id){
        Post::find($id)->delete();
        return response()->json('deleted');
    }

    public function update(Request $request,$id){
        $Post  = Post::find($id);
        $Post->title = $request->input('title');
        $Post->content = $request->input('content');
        $Post->save();

        return response()->json($Post);
    }
}
