class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_group, only: [ :update, :destroy ]

  def cluster
    service = IdeaClusteringService.new(@brainstorm)
    result = service.cluster_ideas

    if result[:success]
      redirect_to brainstorm_path(@brainstorm), notice: result[:message]
    else
      redirect_to brainstorm_path(@brainstorm), alert: result[:message]
    end
  end

  def create
    @group = @brainstorm.groups.build(group_params)
    # 最後のpositionの次の番号を設定
    @group.position = @brainstorm.groups.maximum(:position).to_i + 1

    if @group.save
      redirect_to brainstorm_path(@brainstorm), notice: "グループを作成しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "グループの作成に失敗しました"
    end
  end

  def update
    if @group.update(group_params)
      redirect_to brainstorm_path(@brainstorm), notice: "グループ名を更新しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "グループ名の更新に失敗しました"
    end
  end

  def destroy
    @group.destroy
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
      redirect_to brainstorm_path(@brainstorm), notice: "クラスタリングをやり直しました"
    else
      redirect_to brainstorm_path(@brainstorm), alert: "やり直しに失敗しました: #{result[:message]}"
    end
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:brainstorm_id])
  end

  def set_group
    @group = @brainstorm.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
