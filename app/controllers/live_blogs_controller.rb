class LiveBlogsController < ApplicationController
  def show
    @live_blog = LiveBlog.find params[:id]
  end

  def latest
    live_blog = LiveBlog.find params[:id]
    @messages = live_blog.latest_messages
  end
end
