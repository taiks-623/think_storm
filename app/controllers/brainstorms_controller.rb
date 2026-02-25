class BrainstormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm, only: [ :show, :edit, :update, :destroy, :export_markdown ]

  def index
    @brainstorms = current_user.brainstorms.order(created_at: :desc)

    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @brainstorms = @brainstorms.where(
        "title LIKE :keyword OR description LIKE :keyword", keyword: keyword
      )
    end
  end

  def new
    @brainstorm = Brainstorm.new
  end

  def create
    @brainstorm = current_user.brainstorms.build(brainstorm_params)

    if @brainstorm.save
      redirect_to @brainstorm, notice: "ブレストを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @tags = @brainstorm.tags.distinct.order(:name)

    if params[:tag_id].present?
      @selected_tag = @tags.find_by(id: params[:tag_id])
      @filtered_ideas = @brainstorm.ideas.includes(:evaluations, :tags).joins(:tags).where(tags: { id: params[:tag_id] })
    end

    @brainstorm = Brainstorm.includes(ideas: [ :evaluations, :tags, :groups ], evaluation_axes: []).find(@brainstorm.id)
  end

  def edit
  end

  def update
    if @brainstorm.update(brainstorm_params)
      redirect_to @brainstorm, notice: "ブレストを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @brainstorm.destroy
    redirect_to dashboard_path, notice: "ブレストを削除しました"
  end

  def search_suggestions
    if params[:q].present?
      keyword = "%#{params[:q]}%"
      @suggestions = current_user.brainstorms
        .where("title LIKE ?", keyword)
        .order(created_at: :desc)
        .limit(5)
        .pluck(:title)
    else
      @suggestions = []
    end

    render json: @suggestions
  end

  def export_markdown
    content = MarkdownExportService.new(@brainstorm).call
    send_data content,
      filename: "#{@brainstorm.title}.md",
      type: "text/markdown",
      disposition: "attachment"
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:id])
  end

  def brainstorm_params
    params.require(:brainstorm).permit(:title, :description)
  end
end
