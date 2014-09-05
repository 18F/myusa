# HomeController
class HomeController < ApplicationController
  layout 'marketing', only: [:index, :legal]
end
