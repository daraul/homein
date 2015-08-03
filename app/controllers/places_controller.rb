class PlacesController < ApplicationController
  before_action :set_place, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:edit, :update, :destroy, :create, :new]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  # GET /places
  # GET /places.json
  def index
    @places = Place.all
  end

  # GET /places/1
  # GET /places/1.json
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(place_params)

    @place.user = current_user 
    @place.contact = @place.user.email 
    @place.available = true 

    respond_to do |format|
      if @place.save
        @place.index!
        format.html { redirect_to @place, notice: 'Place was successfully created.' }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to @place, notice: 'Place was successfully updated.' }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render :edit }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.remove_from_index!
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url, notice: 'Place was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def search
    if params[:query]
      @places = Place.where("address LIKE ? OR description LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%") 
      
      render 'index' 
    else 
      if params[:price].to_i > 0
        @places = Place.where(
          "description LIKE ? AND address LIKE ? AND rooms > ? AND bathrooms > ? AND price <= ?", 
          "%#{params[:description]}%", 
          "%#{params[:address]}%", 
          params[:rooms].to_i, 
          params[:bathrooms].to_i,
          params[:price].to_i
        )

        render 'index'
      else 
        @places = Place.where(
          "description LIKE ? AND address LIKE ? AND rooms > ? AND bathrooms > ?", 
          "%#{params[:description]}%", 
          "%#{params[:address]}%", 
          params[:rooms].to_i, 
          params[:bathrooms].to_i
        )

        render 'index'
      end
    end 
  end 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
      @place = Place.find(params[:id])
    end

    def authorize_user 
      if @place.user != current_user
        flash.alert = "You're not authorized to do that!"

        redirect_to root_path
      end 
    end 

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.require(:place).permit(:description, :address, :latitude, :longitude, :rooms, :bathrooms, :available, :price, :contact)
    end
end
