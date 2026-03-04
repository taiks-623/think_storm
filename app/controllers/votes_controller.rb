class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea

  def create
    @vote = @idea.votes.build(user: current_user)

    if @vote.save
      BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to brainstorm_path(@brainstorm) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("vote-#{@idea.id}", partial: "votes/button", locals: { idea: @idea, brainstorm: @brainstorm }) }
        format.html { redirect_to brainstorm_path(@brainstorm), alert: "投票に失敗しました" }
      end
    end
  end

  def destroy
    @vote = @idea.votes.find_by(user: current_user)
    @vote&.destroy

    BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
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
