class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def sort_params
    params.permit(:sort_by)
  end

  def ratings_params
    return params[:ratings].keys if params[:ratings].present?
    Movie.all_ratings
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.where( rating: ratings_params )
    @sort_by = sort_params[:sort_by].try(:to_sym)
    sort_movies(@movies, @sort_by) if @sort_by.present?

    @all_ratings = Movie.all_ratings
    @checked_ratings = ratings_params
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def sort_movies(movies, sort_by)
    return unless [:title, :release_date].include?(sort_by)
    movies.order!(sort_by)
  end

end
