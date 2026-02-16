class IdeasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea, only: [ :edit, :update, :destroy ]

  def create
    @idea = @brainstorm.ideas.build(idea_params)
    @idea.source = "user"

    if @idea.save
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアを追加しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "アイデアの追加に失敗しました"
    end
  end

  def generate
    service = IdeaGeneratorService.new(@brainstorm)
    ideas_data = service.generate_ideas(count: 15)

    if ideas_data.any?
      ideas_data.each do |idea_data|
        @brainstorm.ideas.create(idea_data)
      end
      redirect_to brainstorm_path(@brainstorm), notice: "#{ideas_data.count}個のアイデアを生成しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "アイデアの生成に失敗しました"
    end
  end

  def edit
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
