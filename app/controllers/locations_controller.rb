class LocationsController < ApplicationController
  before_action :set_location, only: %i[ show edit update destroy ]
  # skip_before_action :authenticate_user!, only: %i[ index ]
  before_action :allow_for_editor, only: %i[ index edit update destroy create ]

  def index
    @locations = Location.all
  end

  def show
  end

  def new
    @location = Location.new
  end

  def edit
  end

  def create
    @location = Location.new(location_params)
    saved = @location.save
    if params[:booklet_id].present?
      Booklet.find(params[:booklet_id]).update(genesis_location_id: @location.id)
    elsif params[:ownership_id].present?
      Ownership.find(params[:ownership_id]).update(location_id: @location.id)
    elsif params[:modern_source_id].present?
      ModernSource.find(params[:modern_source_id]).update(publication_location_id: @location.id)
    elsif params[:institution_id].present?
      Institution.find(params[:institution_id]).update(location_id: @location.id)
    elsif params[:booklist_id].present?
      Booklist.find(params[:booklist_id]).update(location: @location)
    end
    if saved && !request.xhr?
      # redirect_path = params[:booklet_id].present? ? edit_manuscript_booklet_path(Booklet.find(params[:booklet_id]).manuscript, params[:booklet_id]) : locations_path
      # redirect_to redirect_path, notice: "Location was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @location.update(location_params)
      if request.xhr?
        render :json => {"status": "updated"}  
      else
        redirect_to locations_url, notice: "Location was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @location.destroy
      redirect_to locations_url, notice: "Location was successfully destroyed."
    rescue StandardError => e
      redirect_to locations_url, alert: "Object could not be deleted because it's being used somewhere else in the system"
    end
  end

  private
    def set_location
      @location = Location.find(params[:id])
    end

    def location_params
      params.require(:location).permit(:country, :city_english, :city_orig, :city_translilteration, :region_english, :region_orig, :region_transliteration, :diocese_english, :diocese_orig, :diocese_transliteration, :longitude, :latitude, :city_orig_writing_system_id, :region_orig_writing_system_id, :diocese_orig_writing_system_id)
    end
end
