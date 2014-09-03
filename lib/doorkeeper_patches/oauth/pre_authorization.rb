class Doorkeeper::OAuth::PreAuthorization
  def initialize(server, client, resource_owner, attrs = {})
    @server           = server
    @client           = client
    @resource_owner   = resource_owner
    @response_type    = attrs[:response_type]
    @redirect_uri     = attrs[:redirect_uri]
    @scope            = attrs[:scope]
    @state            = attrs[:state]
  end

  def validate_scopes
    return true unless scope.present?
    Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(scope, server.scopes) &&
      Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(scope, client.application.scopes)
  end

  def validate_client
    client.present? && client.valid_for?(@resource_owner)
  end
end
