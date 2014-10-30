ActiveAdmin.register Place do

  menu parent: 'Directory'

  permit_params :name, :category, :rus_name, :translate

  scope :translate
  scope :untranslate

  index do
    column :translate
    column :name
    column :rus_name
    column :translate do |place|
      text_field_tag place.id, '', class: :translate
    end
    actions
  end

  # Контроллер перевода
  member_action :translate, method: :put do
    head :fault and return if params[:translate].blank?
    place = Place.find(params[:id])
    place.rus_name = params[:translate]
    place.translate = true
    place.save

    render json: place
  end


end
