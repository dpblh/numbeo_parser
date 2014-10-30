ActiveAdmin.register City do

  menu parent: 'Directory'

  permit_params :name, :country_id, :rus_name, :analyzed, :translate

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
    column :translate do |city|
      text_field_tag city.id, '', class: :translate
    end
    actions
  end

  show do |city|
    attributes_table do
      row :id
      row :translate
      row :analyzed
      row :name
      row :rus_name
      row :country
      row :created_at
      row :updated_at
    end

    City.hash_category_places(city).each do |key, value|
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
      resource_class.includes(place_positions: [:place, :currency])
    end
  end

  # Контроллер перевода
  member_action :translate, method: :put do
    head :fault and return if params[:translate].blank?
    city = City.find(params[:id])
    city.rus_name = params[:translate]
    city.translate = true
    city.save

    render json: city
  end



end
