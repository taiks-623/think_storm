class BrainstormsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm, only: [ :show, :edit, :update, :destroy ]

  def index
    @brainstorms = current_user.brainstorms.order(created_at: :desc)
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
    @brainstorm.ideas.reload
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

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:id])
  end

  def brainstorm_params
    params.require(:brainstorm).permit(:title, :description)
  end
end
