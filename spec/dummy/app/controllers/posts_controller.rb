class PostsController < ApplicationController

  def index
    @users = User.all
  end

end
