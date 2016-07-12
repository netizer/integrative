class Flag
  include Integrative::Integrated

  attr_accessor :id
  attr_accessor :user_id
  attr_accessor :name

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
        id: 1,
        user_id: frank.id,
        name: :admin
      },
      {
        id: 2,
        user_id: frank.id,
        name: :editor
      },
      {
        id: 3,
        user_id: mark.id,
        name: :editor
      }
    ]
  end

  def self.integrative_find(ids, integration)
    response = find(ids)
    response.map { |item| self.new(item) }
  end
end
