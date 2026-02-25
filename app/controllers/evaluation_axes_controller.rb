class EvaluationAxesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm

  def create
    @evaluation_axis = @brainstorm.evaluation_axes.build(evaluation_axis_params)
    if @evaluation_axis.save
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
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @brainstorm }
    end
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:brainstorm_id])
  rescue ActiveRecord::RecordNotFound
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def evaluation_axis_params
    params.require(:evaluation_axis).permit(:name, :position)
  end
end
