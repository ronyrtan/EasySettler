class CitiesController < ApplicationController
  before_action :check_for_admin, :only => [:edit, :create, :new, :destroy, :update]
  before_action :find_or_initialize_city, :except => [:index]
  autocomplete :city, :name

  def index
    @cities = City.all

    if params[:search]
      @cities = City.search(params[:search]).order("created_at DESC")
      @city = City.find_by :name => params[:search]
    else
      @cities = City.all.order('created_at DESC')
    end

    if @cities.length == 1
      redirect_to @cities.first
    else
      render :index
    end
  end

  def show
    @articles = current_city.articles
    @default_articles = @articles.where(category_id: 1)
    @categories = Category.all
  end

  def articles_category
    @all_articles = @city.articles

    chosen_category = params[:category]

    if chosen_category == 'All'
      @all_articles = @city.articles
    else
      @all_articles = Article.per_city_and_category(@city.id, chosen_category)
    end

    respond_to do |format|
      format.html { redirect_to "#" }
      format.js
    end

  end

  def new
  end

  def create
    @city = City.new(city_params)

    if @city.save
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @city.update(city_params)
      redirect_to @city
    else
      render :edit
    end
  end

  def destroy
    @city.destroy
    redirect_to root_path
  end

  def submit_rating
    city_id = params[:id]
    feedback = params[:feedback]
    rating = params[:rating]

    city_feedback = Feedback.check_exists(current_user.id, feedback, city_id)

    if city_feedback.present?
      feedback_id = city_feedback.first.id
      update_data = { feedback => rating.to_f }
      city_feedback.update(feedback_id, update_data)
      redirect_to '#'
    else
      city_feedback = Feedback.new :city_id => city_id, feedback => rating, :user_id => current_user.id
      city_feedback.save
      redirect_to '#'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def find_or_initialize_city
    @city = params[:id] ? City.where(:id => params[:id]).first : City.new
  end

  def city_params
    params.fetch(:city, {}).permit(:name, :country, :description, :population, :slogan)
  end
end
