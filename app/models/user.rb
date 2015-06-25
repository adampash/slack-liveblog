require 'slack_client'

class User < ActiveRecord::Base
  has_many :messages
  has_attached_file :avatar,
    :styles => { :large => "192x192>", :thumb => "100x100>" },
    :default_url => "/assets/images/:style/missing.png",
    :storage => :s3,
    :path => "liveblog/#{Rails.env.development? ? 'testing/' : ''}users/avatar/:id/:style/:id",
    :s3_credentials => Proc.new{|a| a.instance.s3_credentials }

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def self.find_or_create(options)
    user = find_by(slack_id: options[:user_id])
    if user.nil?
      user = create(
        slack_id: options[:user_id],
        name: options[:user_name],
      )
      delay.fetch_user(user.id)
    end
    user
  end

  def self.find_or_create_by_slack_id(slack_id)
    user = find_by(slack_id: slack_id)
    if user.nil?
      user = create(
        slack_id: slack_id,
      )
      fetch_user(user.id)
    end
    user
  end

  def self.find_or_create_bot(bot_name, bot_id)
    user = find_by(slack_id: bot_id)
    if user.nil?
      user = create(
        slack_id: bot_id,
        name: bot_name,
      )
      if bot_name == "TwitterBot"
        twitter_avatar = "https://slack.global.ssl.fastly.net/7bf4/img/services/twitter_128.png"
        user.get_avatar_from_url(twitter_avatar)
      end
      user.save
    end
    user
  end

  def self.fetch_user(user_id)
    user = find(user_id)
    puts "need to fetch stuff for this user: #{user.name}"
    response = SlackClient.users_info user: user.slack_id
    profile = response["user"]["profile"]
    user.real_name = profile["real_name"]
    user.name = response["user"]["name"]
    avatar_url = profile["image_192"]
    user.get_avatar_from_url(avatar_url)
    user.save
  end

  def display_name
    real_name or name
  end

  def get_avatar_from_url(url)
    self.avatar = open(url)
  end

  def s3_credentials
    {
      :bucket => ENV["AWS_BUCKET"],
      :access_key_id => ENV["AWS_ACCESS_KEY"],
      :secret_access_key => ENV["AWS_SECRET_KEY"],
    }
  end

end
