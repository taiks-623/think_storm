class BrainstormChannel < ApplicationCable::Channel
  def subscribed
    brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])

    if brainstorm && (brainstorm.owner?(current_user) || brainstorm.member?(current_user))
      stream_for brainstorm
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
