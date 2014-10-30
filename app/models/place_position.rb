class PlacePosition < ActiveRecord::Base
  belongs_to :city
  belongs_to :country
  belongs_to :place
  belongs_to :currency
  has_one :country, through: :city

  # validates :city_id, presence: true
  # validates :place_id, presence: true
  validates :currency_id, presence: true

end
