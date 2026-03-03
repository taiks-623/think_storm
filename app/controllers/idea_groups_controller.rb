class IdeaGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :require_editor!
  before_action :set_idea

  def update_group
    new_group = @brainstorm.groups.find_by(id: params[:group_id])

    @idea.idea_groups.destroy_all

    if new_group
      @idea.groups << new_group
      message = "アイデアを移動しました"
    else
      message = "アイデアをグループから外しました"
    end

    # ブロードキャスト
    BrainstormChannel.broadcast_to(
      @brainstorm,
      event: "group_updated"
    )

    respond_to do |format|
      format.html { redirect_to brainstorm_path(@brainstorm), notice: message }
      format.json { head :no_content }
    end
  end

  private

  def set_brainstorm
    @brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])
    unless @brainstorm && (@brainstorm.owner?(current_user) || @brainstorm.member?(current_user))
      redirect_to brainstorms_path, alert: "ブレストが見つかりません"
    end
  end

  def require_editor!
    unless @brainstorm.editor?(current_user)
      redirect_to @brainstorm, alert: "編集権限がありません"
    end
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:id])
  end
end
