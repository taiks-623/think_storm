class EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea

  def create
    @evaluation_axis = @brainstorm.evaluation_axes.find(params[:evaluation_axis_id])
    @evaluation = @idea.evaluations.build(
      evaluation_axis: @evaluation_axis,
      score: params[:score]
    )
    if @evaluation.save
      BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
      respond_to do |format|
        format.turbo_stream
      end
    else
      head :unprocessable_entity
    end
  end

  def update
    @evaluation = @idea.evaluations.find(params[:id])
    if @evaluation.update(score: params[:score])
      BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
      respond_to do |format|
        format.turbo_stream
      end
    else
      head :unprocessable_entity
    end
  end

  private

  def set_brainstorm
    @brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])
    unless @brainstorm && (@brainstorm.owner?(current_user) || @brainstorm.member?(current_user))
      redirect_to brainstorms_path, alert: "ブレストが見つかりません"
    end
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:idea_id])
  rescue ActiveRecord::RecordNotFound
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end
end
