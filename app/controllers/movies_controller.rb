class MoviesController < ApplicationController
  def index
    @movies = Movie.all.order('status, release_date ASC')

    if params[:status].present?
      @movies = @movies.where(status: Movie.statuses[params[:status]])
    end
    if params[:name].present?
      @movies = @movies.where('name ILIKE ?', "%#{params[:name]}%")
    end
    if params[:start_date].present? && params[:end_date].present?
      start_date  = params[:start_date].split('/')[2]+'-'+params[:start_date].split('/')[1]+'-'+params[:start_date].split('/')[0]
      end_date    = params[:end_date].split('/')[2]+'-'+params[:end_date].split('/')[1]+'-'+params[:end_date].split('/')[0]
      @movies = @movies.where('release_date >= ? AND release_date <= ?', "%#{start_date}%", "%#{end_date}%")
    end

    @movies = @movies.page(params[:page]).per(24)
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def new
    @movie = Movie.new
  end

  def edit
    @movie = Movie.find(params[:id])
    @movie.release_date = @movie.release_date.strftime('%d%m%Y')
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to @movie
    else
      render 'new'
    end
  end

  def update
    @movie = Movie.find(params[:id])

    if @movie.update(movie_params)
      redirect_to @movie
    else
      render 'edit'
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy

    redirect_to movies_path
  end

  def image
    @obj = Movie.get_url(params['name'], params['year'])
  end

  private

  def movie_params
    params.require(:movie).permit(:name, :release_date, :status, :director, :gender, :synopsis, :image_link, :original_title, :cast)
  end
end
