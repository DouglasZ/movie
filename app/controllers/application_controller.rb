class ApplicationController < ActionController::Base
  before_action :logged_in_user, :except=>[:new,:create]
  protect_from_forgery with: :exception
  include SessionsHelper

  private
    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        redirect_to login_url
      end
    end
end
