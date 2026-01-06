class IdeasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea, only: [:edit, :update, :destroy]

  def create
    @idea = @brainstorm.ideas.build(idea_params)
    @idea.source = 'user'

    if @idea.save
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアを追加しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "アイデアの追加に失敗しました"
    end
  end

  def edit
    # 編集ページを表示
  end

  def update
    if @idea.update(idea_params)
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアを更新しました"
    else
      render :edit, status: :unprocessable_entity
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
