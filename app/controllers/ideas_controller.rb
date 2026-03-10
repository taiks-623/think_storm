class IdeasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :require_editor!
  before_action :set_idea, only: [ :edit, :update, :destroy ]

  def create
    @idea = @brainstorm.ideas.build(idea_params)
    @idea.source = "user"
    @idea.user = current_user

    if @idea.save
      # ブロードキャスト
      BrainstormChannel.broadcast_to(
        @brainstorm,
        event: "idea_created",
        html: render_to_string(partial: "ideas/idea_card", locals: { idea: @idea, brainstorm: @brainstorm, current_group: nil, current_user_id: current_user.id, is_editor: @brainstorm.editor?(current_user) })
      )
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

      # ブロードキャスト（ページリロードで対応）
      BrainstormChannel.broadcast_to(
        @brainstorm,
        event: "group_updated"
      )

      redirect_to brainstorm_path(@brainstorm), notice: "#{ideas_data.count}個のアイデアを生成しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "アイデアの生成に失敗しました"
    end
  end

  def edit
  end

  def update
    if @idea.update(idea_params)
      # ブロードキャスト
      BrainstormChannel.broadcast_to(
        @brainstorm,
        event: "idea_updated",
        idea_id: @idea.id.to_s,
        html: render_to_string(partial: "ideas/idea_card", locals: { idea: @idea, brainstorm: @brainstorm, current_group: nil, current_user_id: current_user.id, is_editor: @brainstorm.editor?(current_user) })
      )
      redirect_to brainstorm_path(@brainstorm), notice: "アイデアを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @idea.destroy
    # ブロードキャスト
    BrainstormChannel.broadcast_to(
      @brainstorm,
      event: "idea_destroyed",
      idea_id: @idea.id.to_s
    )
    redirect_to brainstorm_path(@brainstorm), notice: "アイデアを削除しました"
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

  def idea_params
    params.require(:idea).permit(:content, :memo)
  end
end
