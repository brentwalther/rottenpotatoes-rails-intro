class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def has_sort_params_set
    return true if params[:sort_by].present?
    if session[:sort_by].present?
      params[:sort_by] = session[:sort_by]
      return false
    end
    true 
  end

  def has_ratings_params_set
    return true if params[:ratings].present?
    if session[:ratings_params].present?
      params[:ratings] = session[:ratings_params]
      return false
    end
    params[:ratings] = Hash[Movie.all_ratings.map { |r| [r, 1] }] 
    true
  end

  def save_filters
    session[:sort_by] = params[:sort_by]
    session[:ratings_params] = params[:ratings]
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if !has_sort_params_set || !has_ratings_params_set
      flash.keep
      redirect_to movies_path(params.slice(:sort_by, :ratings))
      return
    end
    @movies = Movie.where( rating: params[:ratings].keys )
    @sort_by = params[:sort_by].try(:to_sym)
    sort_movies(@movies, @sort_by) if @sort_by.present?

    @all_ratings = Movie.all_ratings
    @checked_ratings = params[:ratings].keys
    save_filters
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
