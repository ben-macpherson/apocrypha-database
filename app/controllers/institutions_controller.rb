class InstitutionsController < ApplicationController
  before_action :set_institution, only: %i[ show edit update destroy ]
  #skip_before_action :authenticate_user!, only: %i[ index ]
  before_action :allow_for_editor, only: %i[ index edit update destroy create ]

  def index
    @institutions = Institution.all.includes(:location, :manuscripts, :institutional_affiliations, :religious_order, :booklets, :ownerships, :booklists, :modern_sources, :writing_system)
    @initial_state = current_user.user_grid_states.find_by(record_type: "Institution").try(:state).try(:to_json).try(:html_safe)
    @initial_filter = current_user.user_grid_states.find_by(record_type: "Institution").try(:filters).try(:to_json).try(:html_safe)
  end

  def show
    if request.xhr?
      render json: {institution: @institution}
    end
  end

  def new
    @institution = Institution.new
  end

  def edit
  end

  def create
    @institution = Institution.new(institution_params)
    saved = @institution.save
    if params[:manuscript_id].present?
      m = Manuscript.find(params[:manuscript_id])
      if params[:genesis].present?
        m.update(genesis_institution_id: @institution.id)
        m.update(genesis_location_id: @institution.location_id) if @institution.location_id.present?
      else
        m.update(institution_id: @institution.id)
      end
      puts m.inspect
    elsif params[:booklet_id].present?
      b = Booklet.find(params[:booklet_id])
      b.update(genesis_institution_id: @institution.id)
      b.update(genesis_location_id: @institution.location_id) if @institution.location_id.present?
    elsif params[:ownership_id].present?
      o = Ownership.find(params[:ownership_id])
      o.update(institution_id: @institution.id)
      o.update(location_id: @institution.location_id) if @institution.location_id.present?
      o.update(religious_order_id: @institution.religious_order_id) if @institution.religious_order_id.present?
    elsif params[:modern_source_id].present?
      ModernSource.find(params[:modern_source_id]).update(institution_id: @institution.id)
    elsif params[:booklist_id]
      Booklist.find(params[:booklist_id]).update(institution: @institution)
    end
    ChangeLog.create(user_id: current_user.id, record_type: 'Institution', record_id: @institution.id, controller_name: 'institution', action_name: 'create') if saved
    if saved && !request.xhr?
      # redirect_path = params[:manuscript_id].present? ? edit_manuscript_path(params[:manuscript_id]) : (params[:booklet_id].present? ? edit_manuscript_booklet_path(Booklet.find(params[:booklet_id]).manuscript, params[:booklet_id]) : institutions_path)
      # redirect_to redirect_path, notice: "Institution was successfully created."
    elsif saved && request.xhr?
      render json: { new_url: institution_path(@institution), id: @institution.id }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:ownership_id].present?
      o = Ownership.find(params[:ownership_id])
      o.update(institution_id: @institution.id)
      o.update(location_id: @institution.location_id) if @institution.location_id.present? && o.location_id.blank?
      o.update(religious_order_id: @institution.religious_order_id) if @institution.religious_order_id.present? && o.religious_order_id.blank?
    end
    if @institution.update(institution_params)
      if params[:manuscript_id].present?
        m = Manuscript.find(params[:manuscript_id])
        m.update(genesis_location_id: @institution.location_id) if @institution.id == m.genesis_institution_id && @institution.location_id.present?
        m.update(genesis_religious_order_id: @institution.religious_order_id) if @institution.id == m.genesis_institution_id && @institution.religious_order_id.present?
      elsif params[:booklet_id].present?
        b = Booklet.find(params[:booklet_id])
        b.update(genesis_location_id: @institution.location_id) if @institution.id == b.genesis_institution_id && @institution.location_id.present?
        b.update(genesis_religious_order_id: @institution.religious_order_id) if @institution.id == b.genesis_institution_id && @institution.religious_order_id.present?
      elsif params[:booklist_id].present?
        bl = Booklist.find(params[:booklist_id]).
        bl.update(location_id: @institution.location_id) if @institution.location_id.present?
        bl.update(location_id: @institution.religious_order_id) if @institution.religious_order_id.present?
      end
      ChangeLog.create(user_id: current_user.id, record_type: 'Institution', record_id: @institution.id, controller_name: 'institution', action_name: 'update')
      if request.xhr?
        render :json => { new_url: institution_path(@institution), id: @institution }  
      else
        # redirect_to institutions_url, notice: "Institution was successfully updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @institution.destroy
      ChangeLog.create(user_id: current_user.id, record_type: 'Institution', record_id: @institution.id, controller_name: 'institution', action_name: 'destroy')
      redirect_to institutions_url, notice: "Institution was successfully destroyed."
    rescue StandardError => e
      redirect_to institutions_url, alert: "Object could not be deleted because it's being used somewhere else in the system"
    end
  end

  private
    def set_institution
      @institution = Institution.find(params[:id])
    end

    def institution_params
      params.require(:institution).permit(:name_alt, :name, :name_transliteration, :writing_system_id, :original_language, :institution_id, :language_id, :location_id, :religious_order_id, :notes)
    end
end
