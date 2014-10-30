class Place < ActiveRecord::Base
  belongs_to :category
  has_many :place_positions

  validates :name, presence: true
  validates :category_id, presence: true

  scope :translate, -> { where(:translate => true) }
  scope :untranslate, -> { where(:translate => false) }
end
