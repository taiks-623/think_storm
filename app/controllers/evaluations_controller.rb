class EvaluationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea
  before_action :require_editor

  def create
    @evaluation_axis = @brainstorm.evaluation_axes.find(params[:evaluation_axis_id])
    @evaluation = @idea.evaluations.build(
      evaluation_axis: @evaluation_axis,
      score: params[:score]
    )
    if @evaluation.save
      broadcast_evaluation_update
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
      broadcast_evaluation_update
      respond_to do |format|
        format.turbo_stream
      end
    else
      head :unprocessable_entity
    end
  end

  private

  def broadcast_evaluation_update
    Turbo::StreamsChannel.broadcast_replace_to(
      @brainstorm,
      target: "idea-card-#{@idea.id}",
      partial: "ideas/idea_card",
      locals: {
        idea: @idea.reload,
        brainstorm: @brainstorm,
        current_group: @idea.groups.first,
        current_user_id: nil,
        is_editor: false
      }
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      @brainstorm,
      target: "evaluation-panel",
      partial: "brainstorms/evaluation_panel",
      locals: { brainstorm: @brainstorm.reload }
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      @brainstorm,
      target: "chart-reinit-flag",
      html: '<span id="chart-reinit-flag" data-reinit="true"></span>'
    )
  end

  def set_brainstorm
    @brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])
    unless @brainstorm && (@brainstorm.owner?(current_user) || @brainstorm.member?(current_user))
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:idea_id])
  rescue ActiveRecord::RecordNotFound
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def require_editor
    unless @brainstorm.owner?(current_user) || @brainstorm.editor?(current_user)
      head :forbidden
    end
  end
end
