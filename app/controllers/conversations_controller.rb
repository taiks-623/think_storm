class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brainstorm
  before_action :set_idea

  def show
    @conversation = @idea.conversations.first_or_create!(brainstorm: @brainstorm)
    @messages = @conversation.messages.order(:created_at)
  end

  def create
    @conversation = @idea.conversations.first_or_create!(brainstorm: @brainstorm)
    service = IdeaDeepDiveService.new(@conversation)
    result = service.chat(params[:message])

    if result[:success]
      @assistant_message = @conversation.messages.order(:created_at).last
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to brainstorm_idea_conversation_path(@brainstorm, @idea) }
      end
    else
      respond_to do |format|
        format.html { redirect_to brainstorm_idea_conversation_path(@brainstorm, @idea), alert: result[:message] }
      end
    end
  end

  private

  def set_brainstorm
    @brainstorm = current_user.brainstorms.find(params[:brainstorm_id])
  rescue ActiveRecord::RecordNotFound
    render file: "public/404.html", status: :not_found
  end

  def set_idea
    @idea = @brainstorm.ideas.find(params[:idea_id])
  rescue ActiveRecord::RecordNotFound
    render file: "public/404.html", status: :not_found
  end
end
