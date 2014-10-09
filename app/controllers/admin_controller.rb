class AdminController < ApplicationController
  before_filter :require_admin!

  def test
    # binding.pry
    render :text => 'errp!'
  end
end
