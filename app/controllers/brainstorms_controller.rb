class BrainstormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm, only: [ :show, :edit, :update, :destroy, :export_markdown ]
  before_action :require_editor!, only: [ :edit, :update ]
  before_action :require_owner!, only: [ :destroy ]
  before_action :set_brainstorm, only: [ :show, :edit, :update, :destroy, :export_markdown, :invite, :create_invitation ]
  before_action :require_owner!, only: [ :destroy, :invite, :create_invitation ]

  def index
    owned_ids = current_user.brainstorms.pluck(:id)
    shared_ids = current_user.shared_brainstorms.pluck(:id)
    @brainstorms = Brainstorm.where(id: owned_ids + shared_ids)
                            .order(created_at: :desc)

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
      owned_ids = current_user.brainstorms.pluck(:id)
      shared_ids = current_user.shared_brainstorms.pluck(:id)
      @suggestions = Brainstorm.where(id: owned_ids + shared_ids)
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

  def invite
    @editor_invitation = @brainstorm.brainstorm_invitations.find_or_initialize_by(role: "editor")
    @viewer_invitation = @brainstorm.brainstorm_invitations.find_or_initialize_by(role: "viewer")
  end

  def create_invitation
    role = params[:role].presence_in(%w[editor viewer])
    unless role
      redirect_to invite_brainstorm_path(@brainstorm), alert: "無効なロールです"
      return
    end

    invitation = @brainstorm.brainstorm_invitations.find_or_create_by!(role: role)
    redirect_to invite_brainstorm_path(@brainstorm), notice: "#{role == 'editor' ? '編集者' : '閲覧者'}用の招待リンクを生成しました"
  end

  private

  def set_brainstorm
    @brainstorm = Brainstorm.find_by(id: params[:id])
    unless @brainstorm && (@brainstorm.owner?(current_user) || @brainstorm.member?(current_user))
      redirect_to brainstorms_path, alert: "ブレストが見つかりません"
    end
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

  def brainstorm_params
    params.require(:brainstorm).permit(:title, :description)
  end
end
