class User < ActiveRecord::Base

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

  def self.fetch_user(user_id)
    user = find(user_id)
    puts "need to fetch stuff for this user: #{user.name}"
  end
end
