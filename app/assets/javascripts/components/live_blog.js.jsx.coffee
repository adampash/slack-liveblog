@LiveBlog = React.createClass
  getInitialState: ->
    messages: @props.messages,
    live: @props.live,
    loading: false,

  timer: null

  resize: ->
    height = $('.liveblog').height() + 100
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
      # @timer = setInterval @getLatest, 5000 # every 5 seconds
      @timer = setInterval @getNext, 4000 # every 5 seconds
    setTimeout @resize, 1000
    setTimeout @resize, 5000

  componentWillUnmount: ->
    clearInterval @timer

  getLatest: (count=5) ->
    $.ajax
      method: "GET"
      url: "/latest/#{@props.live_blog.id}.json"
      dataType: "json"
      data:
        count: count
      success: (response) =>
        old_messages = @state.messages
        new_messages = response.messages
        if Math.random() * 100 > 50
          setTimeout @resize, 100
        return if old_messages[0]?.id is new_messages[0]?.id and response.live
        messages = _.uniq(new_messages.concat old_messages)
        state =
          messages: messages
          live: response.live
        clearInterval @timer unless @state.live
        if old_messages.length is 0
          state["cursor"] = messages[-1..-1][0].cursor
        @setState state
        # need to figure this OUT
        setTimeout @resize, 100
        setTimeout @resize, 500
        setTimeout @resize, 1000
        setTimeout @resize, 3000
      error: (e) =>
        console.warn "ERROR"
        @

  getNext: ->
    return if @state.messages.length is 0
    cursor = @state.messages[0]?.cursor
    $.ajax
      method: "GET"
      url: "/next/#{@props.live_blog.id}/cursor/#{cursor}.json"
      dataType: "json"
      success: (response) =>
        old_messages = @state.messages
        new_messages = response.messages
        if Math.random() * 100 > 50
          setTimeout @resize, 100
        # return if old_messages[0]?.id is new_messages[0]?.id and response.live
        return if new_messages.length is 0 and response.live
        messages = new_messages.concat old_messages
        state =
          messages: messages
          live: response.live
        clearInterval @timer unless @state.live
        if old_messages.length is 0
          state["cursor"] = messages[-1..-1][0].cursor
        @setState state
        # need to figure this OUT
        setTimeout @resize, 100
        setTimeout @resize, 500
        setTimeout @resize, 1000
        setTimeout @resize, 3000
      error: (e) =>
        console.warn "ERROR"
        @



  fetchMore: ->
    @setState
      loading: true
    $.ajax
      method: "GET"
      dataType: 'json'
      url: "/live_blogs/#{@props.live_blog.id}/cursor.json"
      data: cursor: @state.cursor
      success: (response) =>
        old_messages = @state.messages
        messages = _.uniq(old_messages.concat response)
        state =
          messages: messages
          cursor: messages[-1..-1][0].cursor
        @setState state
        # need to figure this garbage out
        setTimeout @resize, 100
        setTimeout @resize, 500
        setTimeout @resize, 1000
        setTimeout @resize, 3000
        setTimeout @resize, 5000
      error: (e) =>
        debugger
      complete: =>
        @setState
          loading: false

  updateUnprocessed: (message) ->
    messages = @state.messages
    replaceAt = _.findIndex messages, (old_message) ->
      old_message.id is message.id
    messages[replaceAt] = message
    @setState
      messages: messages

  showMoreButton: ->
    @state.cursor? and @state.cursor != 0 and @state.cursor != 1

  render: ->
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
        updateUnprocessed={_this.updateUnprocessed}
        key={message.id}
        hide={hide}
        resize={_this.resize}
      />`

    if @showMoreButton()
      if @state.loading
        more_button = `<div className="loading">
          <i className="fa fa-spinner fa-pulse" />
          </div>`
      else
        more_button = `<button
            onClick={this.fetchMore}
            className="load_more"
          >
            Load More
          </button>`
    else
      more_button = `<div></div>`

    unless @state.live
      ended = `<div>
                  The {this.props.name} live blog has ended.
               </div>`

    `<div className="liveblog">
      <div className={this.state.live ? "header live" : "header ended" }>
        <h3>{this.props.name} Live Blog</h3>
        <div className="status">
          <span className="record" />
          <div className={this.state.live ? "live" : "ended"}>{ended}</div>
        </div>
      </div>
      <div className="messages">
        {messages}
        {more_button}
      </div>
    </div>`
