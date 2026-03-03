class EvaluationAxesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm

  def create
    @evaluation_axis = @brainstorm.evaluation_axes.build(evaluation_axis_params)
    if @evaluation_axis.save
      BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @brainstorm }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("evaluation_axis_form", partial: "evaluation_axes/form", locals: { brainstorm: @brainstorm, evaluation_axis: @evaluation_axis }) }
        format.html { redirect_to @brainstorm, alert: @evaluation_axis.errors.full_messages.join(", ") }
      end
    end
  end

  def update
    @evaluation_axis = @brainstorm.evaluation_axes.find(params[:id])
    if @evaluation_axis.update(evaluation_axis_params)
      BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @brainstorm }
      end
    else
      respond_to do |format|
        format.html { redirect_to @brainstorm, alert: @evaluation_axis.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @evaluation_axis = @brainstorm.evaluation_axes.find(params[:id])
    @evaluation_axis.destroy
    BrainstormChannel.broadcast_to(@brainstorm, event: "group_updated")
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @brainstorm }
    end
  end

  private

  def set_brainstorm
    @brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])
    unless @brainstorm && (@brainstorm.owner?(current_user) || @brainstorm.member?(current_user))
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
  end

  def evaluation_axis_params
    params.require(:evaluation_axis).permit(:name, :position)
  end
end
