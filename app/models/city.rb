class City < ActiveRecord::Base
  belongs_to :country
  has_many :place_positions, dependent: :destroy

  scope :translate, -> { where(:translate => true) }
  scope :untranslate, -> { where(:translate => false) }
  scope :analyzed, -> { where(:analyzed => true) }
  scope :unanalyzed, -> { where(:analyzed => false) }

  class << self

    def hash_category_places(city)
      pps = where(id: city.id).includes(place_positions: [place: [:category]])
      hash = {}
      if pps.first
        pps.first.place_positions.each { |pp|
          category_name = pp.place.category.name
          if hash[category_name]
            hash[category_name] << pp
          else
            hash[category_name] = [pp]
          end
        }
      end
      hash
    end

  end
end
