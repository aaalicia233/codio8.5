Rottenpotatoes::Application.routes.draw do
  resources :movies
  # map '/' to be a redirect to '/movies'
  root to: redirect('/movies')
  get 'search' => 'movies#search_tmdb', as: 'search'
  post 'add_movie' => 'movies#add_movie', as: 'add_movie'
end
