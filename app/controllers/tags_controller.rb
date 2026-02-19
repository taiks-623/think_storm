class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea

  def create
    tag_name = params[:tag][:name].to_s.strip

    return redirect_to brainstorm_path(@brainstorm), alert: "タグ名を入力してください" if tag_name.blank?

    tag = @brainstorm.tags.find_or_create_by(name: tag_name)

    unless @idea.tags.include?(tag)
      @idea.tags << tag
    end

    redirect_to edit_brainstorm_idea_path(@brainstorm, @idea), notice: "タグを追加しました"
  end

  def destroy
    tag = @brainstorm.tags.find(params[:id])
    @idea.tags.delete(tag)
    tag.destroy if tag.ideas.empty?

    redirect_to edit_brainstorm_idea_path(@brainstorm, @idea), notice: "タグを削除しました"
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:brainstorm_id])
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:idea_id])
  end
end
