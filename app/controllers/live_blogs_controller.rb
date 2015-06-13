class LiveBlogsController < ApplicationController
  before_filter :set_cache_control_headers, only: [:show, :latest, :cursor]
  after_action :allow_iframe

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

  private
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

end
