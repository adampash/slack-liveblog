require 'slack'
module SlackClient
  def self.configure
    Slack.configure do |config|
      config.token = ENV["SLACK_API_TOKEN"]
    end
  end

  def self.method_missing(m, *args, &block)
    configure
    Slack.send m, *args
  end
end
