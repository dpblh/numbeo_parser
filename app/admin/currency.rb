ActiveAdmin.register Currency do

  menu parent: 'Directory'

  permit_params :name, :rate, :code

end
