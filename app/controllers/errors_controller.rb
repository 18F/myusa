
# ErrorsController
class ErrorsController < ApplicationController
  layout -> { current_user ? 'dashboard' : 'login' }

  def not_found
  end

  def change_rejected
  end
end
