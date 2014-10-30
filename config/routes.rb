Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  get '/admin/recreate' => 'admin/dashboard#recreate'
  get '/admin/parser' => 'admin/dashboard#numbeo_parser'
  get '/admin/status' => 'admin/dashboard#status_numbeo_parcer'
  get '/admin/cancel_recreate' => 'admin/dashboard#cancel_recreate'
  get '/admin/cancel_numbeo_parser' => 'admin/dashboard#cancel_numbeo_parser'
  put '/admin/translate' => 'admin/dashboard#translate'
  get '/admin/cities/by/country' => 'admin/dashboard#cities_by_country'

  root 'admin/dashboard#index'

end
