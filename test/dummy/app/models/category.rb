class Category < ApplicationRecord
  include Integrative::Integrated

  belongs_to :user

  def self.integrative_find(ids, options)
    find(ids)
  end
end
