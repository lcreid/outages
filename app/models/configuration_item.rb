class ConfigurationItem < ApplicationRecord
  validates :name, presence: true
end
