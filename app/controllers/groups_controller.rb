class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :require_editor!
  before_action :set_group, only: [ :update, :destroy ]

  def cluster
    service = IdeaClusteringService.new(@brainstorm)
    result = service.cluster_ideas

    if result[:success]
      BrainstormChannel.broadcast_to(
        @brainstorm,
        event: "group_updated"
      )
      redirect_to brainstorm_path(@brainstorm), notice: result[:message]
    else
      redirect_to brainstorm_path(@brainstorm), alert: result[:message]
    end
  end

  def create
    @group = @brainstorm.groups.build(group_params)
    @group.position = @brainstorm.groups.maximum(:position).to_i + 1

    if @group.save
      BrainstormChannel.broadcast_to(
        @brainstorm,
        event: "group_updated"
      )
      redirect_to brainstorm_path(@brainstorm), notice: "グループを作成しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "グループの作成に失敗しました"
    end
  end

  def update
    if @group.update(group_params)
      BrainstormChannel.broadcast_to(
        @brainstorm,
        event: "group_updated"
      )
      redirect_to brainstorm_path(@brainstorm), notice: "グループ名を更新しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "グループ名の更新に失敗しました"
    end
  end

  def destroy
    @group.destroy
    BrainstormChannel.broadcast_to(
      @brainstorm,
      event: "group_updated"
    )
    redirect_to brainstorm_path(@brainstorm), notice: "グループを削除しました"
  end

  def reset_clustering
    ActiveRecord::Base.transaction do
      IdeaGroup.where(group_id: @brainstorm.groups.ids).delete_all
      @brainstorm.groups.destroy_all
    end

    service = IdeaClusteringService.new(@brainstorm)
    result = service.cluster_ideas

    if result[:success]
      BrainstormChannel.broadcast_to(
        @brainstorm,
        event: "group_updated"
      )
      redirect_to brainstorm_path(@brainstorm), notice: "クラスタリングをやり直しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "やり直しに失敗しました: #{result[:message]}"
    end
  end

  private

  def set_brainstorm
    @brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])
    unless @brainstorm && (@brainstorm.owner?(current_user) || @brainstorm.member?(current_user))
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
  end

  def require_editor!
    unless @brainstorm.editor?(current_user)
      redirect_to @brainstorm, alert: "編集権限がありません"
    end
  end

  def set_group
    @group = @brainstorm.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
