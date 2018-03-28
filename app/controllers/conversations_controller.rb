class ConversationsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages
    redirect_to request.referrer || root_url if @conversation.nil?
    authority_conversation! current_user, @conversation
  end

  def create
    conversation = Conversation.new(newbie_id: current_user.id, expert_id: params[:applier_id], request_id: params[:request_id])
    if conversation.save
      noti = current_user.send_notifications.create(event: t("views.conversation.notification"), receiver_id: conversation.expert_id, object_type: "conversation", object_id: conversation.id)
      ActionCable.server.broadcast "notification_conversation_channel",
                                   conversation_id: conversation.id,
                                   notification: render_notification(noti),
                                   owner_conversation: conversation.expert_id
      User.transaction do
        users_in_conversation conversation
      end
      redirect_to conversation
    else
      flash[:danger] = conversation.errors.messages[:base][0]
      redirect_to request.referrer || root_url
    end
  end

  def close
    conversation = Conversation.find_by id: params[:conversation_id]
    close_conversation conversation, params[:rate_point]
  end

  private
  def authority_conversation! user, conversation
    if user.id != conversation.expert_id && user.id != conversation.newbie_id
      redirect_to request.referrer || root_url
    end
  end

  def users_in_conversation conversation
    conversation.newbie.update_attributes! free: false
    conversation.expert.update_attributes! free: false
  end

  def close_conversation conversation, rate_point
    conversation.update_attributes! done: true, rate_point: rate_point
    conversation.newbie.update_attributes! free: true
    conversation.expert.update_attributes! free: true
  end

  def render_notification notification
  render_to_string partial: "notifications/notification", locals: {notification: notification}
  end

end
