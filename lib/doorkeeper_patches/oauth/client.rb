class Doorkeeper::OAuth::Client
  def valid_for?(user)
    return true if application.public

    # force memberships to reload (TODO: fix this ... )
    # application.owner_emails = application.owner_emails
    # application.developer_emails = application.developer_emails

    return true if application.owner == user
    return true if application.developer_emails.present? &&
      application.developer_emails.split(' ').include?(user.email)
  end
end
