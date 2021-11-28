class V1::PostsController < ApplicationController
  before_action :authenticate_v1_user!
  before_action :set_post, only: %i[show update destroy]

  def index
    posts = Post.all
    render json: posts
  end

  def show
    render json: @post
  end

  def create
    post = current_v1_user.posts.new(post_params)

    if post.save
      render json: post
    else
      render json: post.errors, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
  end

  private

  def set_post
    @post = current_v1_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content).merge(user_id: current_v1_user.id)
  end
end
