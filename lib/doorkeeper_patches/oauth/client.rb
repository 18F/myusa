class Doorkeeper::OAuth::Client
  def valid_for?(user)
    return true if application.public
    return user == application.owner
  end
end
