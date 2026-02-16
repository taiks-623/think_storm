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
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアを移動しました"
    else
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアをグループから外しました"
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
