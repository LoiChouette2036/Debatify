class CommentsController < ApplicationController
  # after_initialize :set_default_votes, if: :new_record?

  def create
    @topic = Topic.find(params[:topic_id])
    @new_comment = @topic.comments.build(comment_params)
    @new_comment.user = current_user
    @new_comment.votes = 0 # Ensure default votes is set to 0

    if @new_comment.save
      redirect_to topic_path(@topic), notice: 'Comment added successfully!'
    else
      render 'topics/show', status: :unprocessable_entity
    end
  end

  def upvote
    @comment = Comment.find(params[:id])
    if current_user.voted_on?(@comment)
      @comment.votes -= 1
      current_user.remove_vote(@comment)
    else
      @comment.votes += 1
      current_user.upvote(@comment)
    end
    @comment.save
    redirect_to topic_path(@comment.topic)
  end
  private

  def comment_params
    params.require(:comment).permit(:content, :status)
  end

  def set_default_votes
    self.votes ||= 0
  end
end
