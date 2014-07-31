class Api::V1::AuthorizedScopesController < Api::ApiController
  def index
  	scope_list = @token.authorization.try(:scope) || ""
    render json: scope_list.split(/\s+/)
  end
end