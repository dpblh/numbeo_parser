ActiveAdmin.register Place do

  scope :translate
  scope :untranslate

  permit_params :city, :name, :price, :currency, :category, :rus_name

  index do
    column :name, sortable: :name do |place|
      place.rus_name or place.name
    end
    column :translate do |place|
      text_field_tag place.id, '', class: :translate
    end
    column :price, sortable: :price do |place|
      place.price + ' ' + place.currency.name
    end
    # column :city do |place|
    #   place.city.name
    # end
    # column :category do |place|
    #   place.category.name
    # end
    actions

  end

  preserve_default_filters!
  filter :country, as: :select, collection: proc {Country.all}


end
