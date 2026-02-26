class BrainstormInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invitation

  def show
    # 招待リンクを踏んだ時の確認画面
    if @invitation.brainstorm.member?(current_user)
      redirect_to @invitation.brainstorm, notice: "すでにこのブレストのメンバーです"
    end
  end

  def join
    brainstorm = @invitation.brainstorm

    if brainstorm.owner?(current_user) || brainstorm.member?(current_user)
      redirect_to brainstorm, notice: "すでにこのブレストのメンバーです"
      return
    end

    brainstorm.brainstorm_members.create!(
      user: current_user,
      role: @invitation.role
    )

    redirect_to brainstorm, notice: "#{brainstorm.title}に参加しました"
  end

  private

  def set_invitation
    @invitation = BrainstormInvitation.find_by(token: params[:token])
    unless @invitation
      redirect_to brainstorms_path, alert: "招待リンクが無効です"
    end
  end
end
