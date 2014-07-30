class Api::V1::AuthorizedScopesController < Api::ApiController
  def index
  	auth = @token.authorization
    scope_list = auth && auth.scope
    render json: scope_list.split(/\s+/)
  end
end