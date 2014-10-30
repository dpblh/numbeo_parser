ActiveAdmin.register PlacePosition do

  permit_params :price, :place_id, :currency_id, :city_id, :country_id

  batch_action :destroy, :priority => 1 do |selection|
    PlacePosition.where(id: selection).delete_all
    redirect_to collection_path, notice: 'Записи удалены'
  end

  index do
    selectable_column

    column :place, sortable: :place do |place_position|
      place_position.place.rus_name or place_position.place.name
    end
    column :price, sortable: :price do |place_position|
      (place_position.price / place_position.currency.rate).round(2).to_s + ' ' + place_position.currency.name unless place_position.price.zero?
    end
    column :city do |place_position|
      place_position.city.rus_name or place_position.city.name unless place_position.city.nil?
    end
    column :country do |place_position|
      place_position.country.rus_name or place_position.country.name unless place_position.country.nil?
    end

    actions

  end

  show do |place_position|
    attributes_table do
      row :id
      row :price do
        (place_position.price / place_position.currency.rate).round(2) unless place_position.price.zero?
      end
      row :city
      row :country
      row :place
      row :currency
      row :created_at
      row :updated_at
    end
  end

  controller do
    def scoped_collection
      resource_class.includes(:place, :currency, :city, :country)
    end
  end

end
