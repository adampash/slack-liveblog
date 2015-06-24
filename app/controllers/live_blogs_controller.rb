class LiveBlogsController < ApplicationController
  before_filter :set_cache_control_headers, only: [:show, :latest, :cursor, :next_cursor]
  after_action :allow_iframe

  def show
    # @live_blog = LiveBlog.find params[:id]
    @live_blog = LiveBlog.find_cache params[:id]
    set_surrogate_key_header [@live_blog.record_key]
  end

  def latest
    @live_blog = LiveBlog.find_cache params[:id]
    @messages = @live_blog.latest_messages_cache(params[:count])
    set_surrogate_key_header [@live_blog.record_key, @messages.map(&:record_key)].flatten
  end

  def next_cursor
    # need to figure out how to do this while also getting processed messages. maybe return processed message
    @live_blog = LiveBlog.find_cache params[:id]
    @messages = @live_blog.next_cursor_cache(params[:cursor])
    render :latest
    set_surrogate_key_header [@live_blog.record_key, @messages.map(&:record_key)].flatten
  end

  def cursor
    live_blog = LiveBlog.find params[:id]
    @messages = live_blog.from_cursor(params[:cursor])
    set_surrogate_key_header [live_blog.record_key, @messages.map(&:record_key)].flatten
  end

  private
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

end
