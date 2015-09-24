class MoviesController < ApplicationController
  helper_method :ratings_filter, :sort_column, :sort_direction

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    redirect = false
    if params[:ratings] != ratings_filter
      redirect = true
    end
    if params[:sort] != sort_column
      redirect = true
    end

    if session[:ratings] != ratings_filter
      session[:ratings] = ratings_filter
    end
    if session[:sort] != sort_column
      session[:sort] = sort_column
    end

    if redirect
      flash.keep
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    else
      @all_ratings = Movie.ratings
      @movies = Movie.find_by_ratings_and_order params[:ratings].keys, sort_column

    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def ratings_filter
    if params[:ratings]
       params[:ratings]
    elsif !session[:ratings]
       Hash[Movie.ratings.map { |x| [x, 1] }]
    else
       session[:ratings]
    end
  end

  def sort_column
     Movie.column_names.include?(params[:sort]) ? params[:sort] : session[:sort]
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  "asc" : "desc"
  end
end
