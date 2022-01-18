class ModernSourceReferencesController < ApplicationController
  before_action :set_modern_source_reference, only: %i[ show edit update destroy ]

  def index
    @modern_source_references = ModernSourceReference.all
  end

  def show
  end

  def new
    @modern_source_reference = ModernSourceReference.new
  end

  def edit
  end

  def create
    @modern_source_reference = ModernSourceReference.new(modern_source_reference_params)

    if @modern_source_reference.save
      redirect_to modern_source_references_url, notice: "Modern source reference was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @modern_source_reference.update(modern_source_reference_params)
      if request.xhr?
        render :json => {"status": "updated"}  
      else
        redirect_to modern_source_references_url, notice: "Modern source reference was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @modern_source_reference.destroy
    redirect_to modern_source_references_url, notice: "Modern source reference was successfully destroyed."
  end

  private
    def set_modern_source_reference
      @modern_source_reference = ModernSourceReference.find(params[:id])
    end

    def modern_source_reference_params
      params.require(:modern_source_reference).permit(:record_id, :modern_source_id, :specific_page, :siglum)
    end
end