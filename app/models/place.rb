class Place < ActiveRecord::Base
  belongs_to :city
  belongs_to :currency
  belongs_to :category
  has_one :country, through: :city

  validates :name, presence: true
  validates :city_id, presence: true
  validates :currency_id, presence: true
  validates :category_id, presence: true

  scope :translate, -> { where(:translate => true) }
  scope :untranslate, -> { where(:translate => false) }
end
