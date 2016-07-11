class RecentlyAddedUser
  include Integrative::Integrated

  def self.integrative_find(ids, integration)
    category_to_id = User.where(category_id: ids).group(:category_id).maximum(:id)
    User.find(category_to_id.values)
  end
end
