class City < ActiveRecord::Base
  belongs_to :country
  has_many :places, dependent: :destroy
end
