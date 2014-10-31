require 'simple_role'

ActionDispatch::ExceptionWrapper.rescue_responses['SimpleRole::AccessDenied'] = :not_found
