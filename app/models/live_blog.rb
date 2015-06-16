class LiveBlog < ActiveRecord::Base
  has_many :messages
  belongs_to :user
  after_update :purge_cache
  after_save :purge_cache

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

  def self.find_cache(id)
    in_cache = Rails.cache.read("live_blog/#{id}")
    if in_cache
      puts "CACHED LIVEBLOG"
      live_blog = in_cache
    else
      puts "NOT CACHED LIVEBLOG"
      live_blog = LiveBlog.find(id)
      Rails.cache.write(
        "live_blog/#{id}",
        live_blog,
        expires_in: 30.seconds,
      )
    end
    live_blog
  end

  def self.active(channel_id)
    find_by(channel_id: channel_id, live: true)
  end

  def latest_messages(count)
    messages.order('timestamp DESC').limit(count).where(processed: true)
  end

  def latest_messages_cache(count)
    in_cache = Rails.cache.read("latest/#{id}/#{count}")
    if in_cache
      puts "CACHED MESSSAGES"
      messages = in_cache
    else
      puts "NOT CACHED MESSSAGES"
      messages = latest_messages(count)
      Rails.cache.write(
        "latest/#{id}/#{count}",
        messages,
        expires_in: 30.seconds,
      )
    end
    messages
  end

  def from_cursor(cursor)
    messages.where('cursor < ?', cursor).order('cursor DESC').limit(40).where(processed: true)
  end

  protected
  def purge_cache
    Rails.cache.delete("live_blog/#{id}")
    Rails.cache.delete("latest/#{id}/5")
    Rails.cache.delete("latest/#{id}/30")
    purge
  end

end
