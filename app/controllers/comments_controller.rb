class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea

  def create
    @comment = @idea.comments.build(content: params[:content] || params.dig(:comment, :content), user: current_user)

    if @comment.save
      BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to brainstorm_path(@brainstorm) }
      end
    else
      respond_to do |format|
        format.html { redirect_to brainstorm_path(@brainstorm), alert: "コメントの投稿に失敗しました" }
      end
    end
  end

  def destroy
    @comment = @idea.comments.find(params[:id])

    if @comment.user == current_user || @brainstorm.owner?(current_user)
      @comment.destroy
      BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to brainstorm_path(@brainstorm) }
    end
  end

  private

  def set_brainstorm
    @brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])
    unless @brainstorm && (@brainstorm.owner?(current_user) || @brainstorm.member?(current_user))
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:idea_id])
  end
end
