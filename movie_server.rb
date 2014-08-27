require 'pg'
require 'sinatra'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

get '/actors' do
  query = "SELECT id, name FROM actors ORDER BY actors.name ASC;"
  @actors = db_connection do |conn|
    conn.exec(query).to_a
  end
  erb :'actors/index'
end

get '/actors/:id' do
  id = params[:id]
  query = "SELECT movies.title, cast_members.character, movies.id
    FROM movies
    JOIN cast_members ON movies.id = cast_members.movie_id
    JOIN actors ON cast_members.actor_id = actors.id
    WHERE actors.id = #{id}"
  @actor_info = db_connection do |conn|
    conn.exec(query)
  end
  erb :'actors/show'
end


get '/movies' do
  query = "SELECT movies.title, movies.year, movies.rating,
    genres.name AS genre, studios.name, movies.id  FROM movies
    JOIN genres ON movies.genre_id = genres.id
    JOIN studios ON movies.studio_id = studios.id
    ORDER BY title ASC;"
  @movies = db_connection do |conn|
    conn.exec(query).to_a
  end

  erb :'movies/index'
end
get '/movies/:id' do
  id = params[:id]
  query = "SELECT genres.name AS genre, studios.name AS studios,
  cast_members.character, actors.name, movies.id, movies.rating,
  actors.id AS actor_ind_id FROM movies
  JOIN genres ON movies.genre_id = genres.id
  JOIN studios ON movies.studio_id = studios.id
  JOIN cast_members ON movies.id = cast_members.movie_id
  JOIN actors ON cast_members.actor_id = actors.id
  WHERE movies.id = #{id}"
  @movie_info = db_connection do |conn|
    conn.exec(query).to_a
  end
  erb :'movies/show'
end


set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'
