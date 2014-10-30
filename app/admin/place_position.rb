ActiveAdmin.register PlacePosition do

  permit_params :price, :place

  index do
    column :place, sortable: :place do |place_position|
      place_position.place.rus_name or place_position.place.name
    end
    column :price, sortable: :price do |place_position|
      place_position.price + ' ' + place_position.currency.name
    end
    column :city do |place_position|
      place_position.city.rus_name or place_position.city.name
    end
    column :country do |place_position|
      place_position.country.rus_name or place_position.country.name
    end

    actions

  end

  controller do
    def scoped_collection
      resource_class.includes(:place, :currency, :city, :country)
    end
  end

end