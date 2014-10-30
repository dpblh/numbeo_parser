ActiveAdmin.register Country do

  menu parent: 'Directory'

  permit_params :name, :rus_name, :analyzed, :translate

  batch_action :destroy, false

  scope :translate
  scope :untranslate
  scope :analyzed
  scope :unanalyzed

  index do
    column :analyzed
    column :translate
    column :name
    column :rus_name
    column :translate do |country|
      text_field_tag country.id, '', class: :translate
    end
    actions
  end

  show do |country|
    attributes_table do
      row :id
      row :translate
      row :analyzed
      row :name
      row :rus_name
      row :created_at
      row :updated_at
    end

    Country.hash_category_places(country).each do |key, value|
      panel key do
        table_for value, class: :place_position do
          column :place do |place_position|
            place_position.place.rus_name or place_position.place.name
          end
          column :price, class: :price do |place_position|
            place_position.price + ' ' + place_position.currency.name
          end
        end
      end

    end
  end

  controller do
    def scoped_collection
      resource_class.includes(:place_positions, cities: [place_positions: [:place, :currency]])
    end
  end

  # Контроллер перевода
  member_action :translate, method: :put do
    head :fault and return if params[:translate].blank?
    country = Country.find(params[:id])
    country.rus_name = params[:translate]
    country.translate = true
    country.save

    render json: country
  end


end
