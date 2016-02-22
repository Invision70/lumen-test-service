<?php

$app->get('/', function() use ($app) {
    return "Try CRUD: /api/v1/post/";
});

$app->group(['prefix' => 'api/v1','namespace' => 'App\Http\Controllers'], function($app)
{
    $app->get('post','PostController@index');

    $app->get('post/{id}','PostController@view');

    $app->post('post','PostController@create');

    $app->put('post/{id}','PostController@update');

    $app->delete('post/{id}','PostController@delete');
});