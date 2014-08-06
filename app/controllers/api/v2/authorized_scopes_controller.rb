
module Api
  module V2
    # AuthorizedScopesController
    class AuthorizedScopesController < Api::ApiController
      # Authorization not needed because any app calling API can ask for
      # authorized scopes

      def index
        scope_list = @token.authorization.try(:scope) || ''
        render json: scope_list.split(/\s+/)
      end
    end
  end
end
