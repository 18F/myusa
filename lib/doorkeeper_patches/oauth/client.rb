class Doorkeeper::OAuth::Client
  def valid_for?(user)
    return true if application.public
    return application.owners.include?(user)
  end
end
