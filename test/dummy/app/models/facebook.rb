class Facebook
  include Integrative::Integrated

  attr_accessor :user_id
  attr_accessor :name

  def initialize(data)
    @id = data[:id]
    @user_id = data[:user_id]
    @name = data[:name]
  end

  # For simplicity this represents fetching data from an external web service
  def self.find(ids)
    ids.map do |id|
      user = User.find(id)
      {
        user_id: user.id,
        name: "FB name of #{user.name}"
      }
    end
  end

  def self.integrative_find(ids, integration)
    response = find(ids)
    response.map { |item| self.new(item) }
  end
end
