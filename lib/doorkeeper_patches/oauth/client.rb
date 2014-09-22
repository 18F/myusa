class Doorkeeper::OAuth::Client
  def valid_for?(user)
    return true if application.public
    return application.members.include?(user)
  end
end
