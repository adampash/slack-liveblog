class LiveBlogsController < ApplicationController
  def show
    @live_blog = LiveBlog.find params[:id]
  end

  def latest
    live_blog = LiveBlog.find params[:id]
    @messages = live_blog.latest_messages
  end

  def cursor
    live_blog = LiveBlog.find params[:id]
    @messages = live_blog.from_cursor(params[:cursor])
  end
end
