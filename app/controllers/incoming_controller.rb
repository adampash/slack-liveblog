require 'slack_client'

class IncomingController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def handle
    case params[:token]
    when ENV["SLACK_START_TOKEN"]
      if params[:command] == '/start_liveblog'
        if LiveBlog.active(params[:channel_id]).nil?
          SlackClient.chat_postMessage(
            iframe_message(live_blog)
          )
          SlackClient.channels_setTopic(
            channel: live_blog.channel_id,
            topic: "LIVE BLOG IN SESSION"
          )
          live_blog = LiveBlog.create_from_params(params)
        end
      end
      if live_blog.nil?
        render text: "This channel already has an active live blog. To end it, type `/end_liveblog`"
      else
        render text: iframe_message(live_blog)
      end
    when ENV["SLACK_END_TOKEN"]
      if params[:command] == '/end_liveblog'
        live_blog = LiveBlog.end_liveblog(params[:channel_id])
      end
      if live_blog.nil?
        render text: "There is no active live blog for this channel"
      else
        SlackClient.channels_setTopic(
          channel: live_blog.channel_id,
          topic: ""
        )
        render text: "Ended the live blog for #{live_blog.name}"
      end
    when ENV["SLACK_OUTGOING_TOKEN"]
      live_blog = LiveBlog.active(params[:channel_id])
      unless live_blog.nil?
        puts "deal with new message"
        Message.create_from_params(params, live_blog.id)
      end
    else
      puts "deal with no message"
      render status: 500
    end
  end

  protected
  def iframe_message(live_blog)
    "Started a new live blog for #{live_blog.name}! To embed your live blog, paste the following iframe code into Kinja:\n\n```<iframe src=\"http://live.gawker-labs.com/live_blogs/#{live_blog.id}\" class=\"custom\" width=\"100%\" height=\"500px\"></iframe>```"
  end
  def bot_message(live_blog)
    {
      text: iframe_message(live_blog),
      channel: live_blog.channel_id,
      username: "LiveBlogBot",
      icon_emoji: ":rocket:",
    }
  end
end
