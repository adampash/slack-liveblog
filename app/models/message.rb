require 'slack_client'

class Message < ActiveRecord::Base
  after_create :purge_cache_all
  after_update :purge_cache
  after_update :purge_cache_all
  after_save :purge_cache
  after_save :purge_cache_all

  belongs_to :live_blog
  belongs_to :user
  has_one :embed

  has_attached_file :attachment,
    # :styles => { :large => "800x800>" },
    :storage => :s3,
    :path => 'liveblog/messages/files/:id/:style/:filename',
    :s3_credentials => Proc.new{|a| a.instance.s3_credentials }

  validates_attachment_content_type :attachment, :content_type => /\Aimage\/.*\Z/

  def self.find_cache(id)
    in_cache = Rails.cache.read("messages/#{id}")
    if in_cache
      puts "CACHED MESSAGE"
      message = in_cache
    else
      puts "NOT CACHED MESSAGE"
      message = Message.find(id)
      Rails.cache.write(
        "messages/#{id}",
        message,
        expires_in: 30.seconds,
      )
    end
    message
  end

  def self.create_from_params(options, live_blog_id)
    message = create_message(options, live_blog_id)
    if message.text.nil?
      puts "need to fetch file"
      delay.create_file(message.id, options[:timestamp])
    elsif has_link(message.text)
      puts "need to fetch embed"
      Embed.delay.create_from_message(message.id)
    end
    puts "created message"
    message
  end

  def self.create_message(options, live_blog_id)
    user = User.find_or_create(options)
    live_blog = LiveBlog.find live_blog_id

    text = options[:text]

    create(
      text: options[:text],
      user_id: user.id,
      timestamp: DateTime.strptime(options[:timestamp],'%s'),
      live_blog_id: live_blog_id,
      cursor: live_blog.messages.count,
      processed: pre_processed?(text),
    )
  end

  def self.pre_processed?(text)
    !text.nil? and !has_link(text)
  end

  def self.has_link(text)
    linkRe = /<(.+\|?.*)>/
    !text.match(linkRe).nil?
  end


  def self.create_file(message_id, timestamp)
    message = find(message_id)
    response = SlackClient.channels_history(
      channel: message.live_blog.channel_id,
      inclusive: 1,
      latest: timestamp,
      count: 1
    )
    if response["ok"]
      data = response["messages"][0]
      message.text = data["text"]
      if data["subtype"] == "file_share"
        # url = data["file"]["url_download"]
        if data["file"]["mimetype"] == "image/gif"
          url = data["file"]["url_private"]
        else
          url = data["file"]["url_private"]
          # if data["file"]["thumb_720"]
          #   url = data["file"]["thumb_720"]
          # else
          #   url = data["file"]["thumb_360"]
          # end
        end
        message.attachment = get_file_from_url(url)
        message.attachment.instance_write :file_name, data["file"]["title"]

        user = User.find_or_create_by_slack_id(data["user"])
        message.user = user
        message.processed = true
      elsif data["subtype"] == 'bot_message'
        unless data["attachments"].nil?
          if data["attachments"].length > 0
            attachment = data["attachments"].first
            if attachment["service_name"] == 'twitter'
              message.text = attachment["pretext"]
              user = User.find_or_create_bot('TwitterBot', data["bot_id"])
              message.embed = Embed.create_from_attachment(
                message,
                attachment
              )
              message.processed = true
              message.user = user
            end
          end
        end
      else
        puts "something went wrong"
      end
      message.save
      message.live_blog.purge
      message.purge
    end
  end

  def self.get_file_from_url(url)
    open(url,
      "Authorization" => "Bearer #{ENV['SLACK_API_TOKEN']}"
    )
  end

  def s3_credentials
    {
      :bucket => ENV["AWS_BUCKET"],
      :access_key_id => ENV["AWS_ACCESS_KEY"],
      :secret_access_key => ENV["AWS_SECRET_KEY"],
    }
  end

  def attachment_url
    cdn_link attachment.url(:original)
  end

  def cdn_link(uri)
    uri.gsub('s3.amazonaws.com/', '')
  end

  protected
  def purge_cache
    Rails.cache.delete("latest/#{live_blog.id}/5")
    Rails.cache.delete("latest/#{live_blog.id}/30")
    Rails.cache.delete("messages/#{id}")
    Rails.cache.delete("cursor/#{live_blog.id}/#{cursor}")
    purge
  end

  def purge_cache_all
    Rails.cache.delete("latest/#{live_blog.id}/5")
    Rails.cache.delete("latest/#{live_blog.id}/30")
    Rails.cache.delete("messages/#{id}")
    Rails.cache.delete("cursor/#{live_blog.id}/#{cursor}")
    purge_all
    live_blog.purge
  end

end
