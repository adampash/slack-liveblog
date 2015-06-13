class Message < ActiveRecord::Base
  belongs_to :live_blog
  belongs_to :user

  def self.create_from_params(options, live_blog_id)
    user = User.find_or_create(options)
    create(
      text: options[:text],
      user_id: user.id,
      timestamp: DateTime.strptime(options[:timestamp],'%s'),
      live_blog_id: live_blog_id,
    )
  end
end
