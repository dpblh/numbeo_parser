class Category < ActiveRecord::Base

  scope :translate, -> { where(:translate => true) }
  scope :untranslate, -> { where(:translate => false) }
end
