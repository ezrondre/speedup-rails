class WelcomeController < ApplicationController
  def index
    @users = User.all
  end

  def error
    User.find 'a'
  end

end
