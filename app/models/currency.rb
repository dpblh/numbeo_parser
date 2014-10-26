class Currency < ActiveRecord::Base
  validates :code, presence: true
end
