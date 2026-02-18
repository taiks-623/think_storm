class IdeaGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea

  def update_group
    new_group = @brainstorm.groups.find_by(id: params[:group_id])

    # 既存の関連を削除
    @idea.idea_groups.destroy_all

    # 新しいグループに関連付け（group_idがあれば）
    if new_group
      @idea.groups << new_group
      message = "アイデアを移動しました"
    else
      message = "アイデアをグループから外しました"
    end

    respond_to do |format|
      format.html { redirect_to brainstorm_path(@brainstorm), notice: message }
      format.json { head :no_content } # JSONリクエストの場合はリダイレクトせず204を返す
    end
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:brainstorm_id])
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:id])
  end
end
