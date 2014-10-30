ActiveAdmin.register Category do

  permit_params :name, :rus_name, :translate


  scope :translate
  scope :untranslate

  index do
    column :translate
    column :name
    column :rus_name
    column :translate do |category|
      text_field_tag category.id, '', class: :translate
    end
    actions
  end

  # Контроллер перевода
  member_action :translate, method: :put do
    head :fault and return if params[:translate].blank?
    category = Category.find(params[:id])
    category.rus_name = params[:translate]
    category.translate = true
    category.save

    render json: category
  end

end
