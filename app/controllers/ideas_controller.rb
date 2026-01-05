class IdeasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea, only: [:update, :destroy]

  def create
    @idea = @brainstorm.ideas.build(idea_params)
    @idea.source = 'user' # 手動追加の場合

    if @idea.save
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアを追加しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "アイデアの追加に失敗しました"
    end
  end

  def update
    if @idea.update(idea_params)
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアを更新しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "アイデアの更新に失敗しました"
    end
  end

  def destroy
    @idea.destroy
    redirect_to brainstorm_path(@brainstorm), notice: "アイデアを削除しました"
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:brainstorm_id])
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:id])
  end

  def idea_params
    params.require(:idea).permit(:content, :memo)
  end
end
