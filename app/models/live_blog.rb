class LiveBlog < ActiveRecord::Base
  has_many :messages
  belongs_to :user

  def self.create_from_params(options)
    user = User.find_or_create(options)

    create(
      user_id: user.id,
      name: options[:text],
      live: true,
      channel_name: options[:channel_name],
      channel_id: options[:channel_id],
    )
  end

  def self.end_liveblog(channel_id)
    live_blog = active(channel_id)
    return nil if live_blog.nil?
    live_blog.update_attributes live: false
    live_blog
  end

  def self.active(channel_id)
    find_by(channel_id: channel_id, live: true)
  end

  def latest_messages
    messages.order('timestamp DESC').limit(20)
  end

end
