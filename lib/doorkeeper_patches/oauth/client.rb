class Doorkeeper::OAuth::Client
  def valid_for?(user)
    return true if application.public
    return true if application.owner == user
    return true if application.developer_emails.present? &&
      application.developer_emails.split(' ').include?(user.email)
  end
end
