class BrainstormChannel < ApplicationCable::Channel
  def subscribed
    brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])

    if brainstorm && (brainstorm.owner?(current_user) || brainstorm.member?(current_user))
      stream_for brainstorm

      online_key = "brainstorm_#{params[:brainstorm_id]}_online"
      online_members = (Rails.cache.read(online_key) || [])
      unless online_members.any? { |m| m[:id] == current_user.id }
        online_members << { id: current_user.id, email: current_user.email }
        Rails.cache.write(online_key, online_members, expires_in: 1.hour)
      end

      BrainstormChannel.broadcast_to(
        brainstorm,
        event: "member_connected",
        user_id: current_user.id,
        email: current_user.email,
        online_members: online_members
      )
    else
      reject
    end
  end

  def unsubscribed
    brainstorm = Brainstorm.find_by(id: params[:brainstorm_id])
    return unless brainstorm

    online_key = "brainstorm_#{params[:brainstorm_id]}_online"
    online_members = (Rails.cache.read(online_key) || [])
    online_members.reject! { |m| m[:id] == current_user.id }
    Rails.cache.write(online_key, online_members, expires_in: 1.hour)

    BrainstormChannel.broadcast_to(
      brainstorm,
      event: "member_disconnected",
      user_id: current_user.id,
      email: current_user.email,
      online_members: online_members
    )

    stop_all_streams
  end
end
