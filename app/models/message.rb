class Message < ActiveRecord::Base
  belongs_to :live_blog
  belongs_to :user

  has_attached_file :attachment,
    :styles => { :large => "800x800>", :thumb => "100x100>" },
    :default_url => "/images/:style/missing.png",
    :storage => :s3,
    :path => 'liveblog/messages/files/:id/:style/:filename',
    :s3_credentials => Proc.new{|a| a.instance.s3_credentials }

  validates_attachment_content_type :attachment, :content_type => /\Aimage\/.*\Z/

  def self.create_from_params(options, live_blog_id)
    message = create_message(options, live_blog_id)
    if options[:text].nil?
      puts "need to fetch file"
      delay.create_file(message.id, options[:timestamp])
    end
    puts "created message"
    message
  end

  def self.create_message(options, live_blog_id)
    user = User.find_or_create(options)

    create(
      text: options[:text],
      user_id: user.id,
      timestamp: DateTime.strptime(options[:timestamp],'%s'),
      live_blog_id: live_blog_id,
    )
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
        url = data["file"]["url_download"]
        message.attachment = get_file_from_url(url)
        message.attachment.instance_write :file_name, data["file"]["title"]
      end
      message.save
    end
  end

  def self.get_file_from_url(url)
    open(url)
  end

  def s3_credentials
    {
      :bucket => ENV["AWS_BUCKET"],
      :access_key_id => ENV["AWS_ACCESS_KEY"],
      :secret_access_key => ENV["AWS_SECRET_KEY"],
    }
  end

end
