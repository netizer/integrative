class Gravatar
  include Integrative::Integrated

  def initialize(data)
    @id = data[:id]
    @user_id = data[:user_id]
    @name = data[:name]
  end

  # For simplicity this represents fetching data from an external web service
  def self.find(ids)
    frank = User.where(name: "Frank").first
    mark = User.where(name: "Mark").first
    [
      {
        user_id: frank.id,
        value: "http://0.gravatar.com/avatar/frank"
      },
      {
        user_id: mark.id,
        value: "http://0.gravatar.com/avatar/mark"
      }
    ]
  end

  def self.integrative_find(ids, integration)
    response = find(ids)
    response.map { |item| OpenStruct.new(item) }
  end
end
