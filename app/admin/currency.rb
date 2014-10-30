ActiveAdmin.register Currency do

  menu parent: 'Directory'

  permit_params :name, :rate, :code

  batch_action :destroy, false

  index do
    column :rate
    column :name
    column :code

    actions
  end

end
