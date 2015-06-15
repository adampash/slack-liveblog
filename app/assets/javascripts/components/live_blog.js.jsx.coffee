@LiveBlog = React.createClass
  getInitialState: ->
    messages: @props.messages,
    live: @props.live,
    loading: false,

  timer: null

  resize: ->
    height = $('.liveblog').height() + 30
    window.top.postMessage(
      JSON.stringify(
        kinja:
          sourceUrl: window.location.href
          resizeFrame:
            height: height
      ), '*'
    )

  componentDidMount: ->
    @getLatest(30)
    if @state.live
      @timer = setInterval @getLatest, 5000 # every 5 seconds
    setTimeout @resize, 1000
    setTimeout @resize, 5000

  componentWillUnmount: ->
    clearInterval @timer

  getLatest: (count=5) ->
    $.ajax
      method: "GET"
      url: "/latest/#{@props.live_blog.id}"
      dataType: "json"
      data:
        count: count
      success: (response) =>
        old_messages = @state.messages
        if Math.random() * 100 > 50
          setTimeout @resize, 100
        return if old_messages[0]?.id is response[0]?.id
        messages = _.uniq(response.concat old_messages)
        state =
          messages: messages
        if old_messages.length is 0
          state["cursor"] = messages[-1..-1][0].cursor
        @setState state
        setTimeout @resize, 100
      error: (e) =>
        console.warn "ERROR"
        @

  fetchMore: ->
    @setState
      loading: true
    $.ajax
      method: "GET"
      dataType: 'json'
      url: "/live_blogs/#{@props.live_blog.id}/cursor"
      data: cursor: @state.cursor
      success: (response) =>
        old_messages = @state.messages
        messages = _.uniq(old_messages.concat response)
        state =
          messages: messages
          cursor: messages[-1..-1][0].cursor
        @setState state
        setTimeout @resize, 1000
      error: (e) =>
        debugger
      complete: =>
        @setState
          loading: false

  render: ->
    # prevHidden = 0
    messages = @state.messages.map (message, index) =>
      if index is 0
        prevUser = null
      else
        prevUser = @state.messages[index-1].user.name
        if prevUser == message.user.name
          hide = true
          prevTimestamp = @state.messages[index-1].timestamp
          if new Date(prevTimestamp) - new Date(message.timestamp) > 300000 # 5min
            hide = false
      `<Message data={message}
        key={message.id}
        hide={hide}
        resize={this.resize}
      />`

    if @state.cursor? and @state.cursor != 0
      if @state.loading
        more_button = `<div className="loading">
          <i className="fa fa-spinner fa-pulse" />
          </div>`
      else
        more_button = `<button
            onClick={this.fetchMore}
            className="load_more"
          >
            Load more
          </button>`
    else
      more_button = `<div></div>`

    `<div className="liveblog">
      <div className="header">
        <h3>{this.props.name} Live Blog</h3>
        <div className="status">
          <div className={this.props.live ? "live" : "ended"} />
        </div>
      </div>
      <div className="messages">
        {messages}
        {more_button}
      </div>
    </div>`
