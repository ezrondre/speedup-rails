class WelcomeController < ApplicationController
  def index
    @users = User.all
  end

  def error
    User.find 'a'
  end

  def redirect
    redirect_to posts_path
  end

end
