module BrainstormAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :set_brainstorm, only: [:show, :edit, :update, :destroy]
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find_by(id: params[:brainstorm_id] || params[:id])
    @brainstorm ||= Brainstorm.joins(:brainstorm_members)
                              .find_by(id: params[:brainstorm_id] || params[:id],
                                       brainstorm_members: { user: current_user })
    redirect_to brainstorms_path, alert: "ブレストが見つかりません" unless @brainstorm
  end

  def require_editor!
    unless @brainstorm.editor?(current_user)
      redirect_to @brainstorm, alert: "編集権限がありません"
    end
  end

  def require_owner!
    unless @brainstorm.owner?(current_user)
      redirect_to @brainstorm, alert: "オーナー権限が必要です"
    end
  end
end
