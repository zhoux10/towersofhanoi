class CommentsController < ApplicationController

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      redirect_to link_url(@comment.link_id)
    else
      @link = Link.find(@comment.link_id)
      flash.now[:errors] = @comment.errors.full_messages
      render :new
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to link_url(@comment.link_id)
  end

  private
  def comment_params
    params.require(:comment).permit(:body).merge(user_id: current_user.id, link_id: params[:link_id])
  end
end
