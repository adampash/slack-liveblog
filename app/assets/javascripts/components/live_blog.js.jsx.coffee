@LiveBlog = React.createClass
  getInitialState: ->
    messages: @props.messages,
    live: @props.live,
    loading: false,

  timer: null

  resize: ->
    height = $('body').height()
    window.top.postMessage(
      JSON.stringify(
        kinja:
          sourceUrl: window.location.href
          resizeFrame:
            height: height
      ), '*'
    )

  componentDidMount: ->
    @getLatest()
    @timer = setInterval @getLatest, 2000 # every 2 seconds

  componentWillUnmount: ->
    clearInterval @timer

  getLatest: ->
    $.ajax
      method: "GET"
      url: "/latest/#{@props.live_blog.id}"
      dataType: "json"
      success: (response) =>
        old_messages = @state.messages
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
        setTimeout @resize, 100
      error: (e) =>
        debugger
      complete: =>
        @setState
          loading: false

  render: ->
    messages = @state.messages.map (message, index) =>
      if index is 0
        prevUser = null
      else
        prevUser = @state.messages[index-1].user.name
      `<Message data={message}
        key={message.id}
        prevUser={prevUser}
      />`

    if @state.cursor? and @state.cursor != 0
      if @state.loading
        more_button = `<div className="loading">
          <i className="fa fa-spinner fa-pulse" />
          </div>`
      else
        more_button = `<button
          onClick={this.fetchMore}>
            Load more
          </button>`
    else
      more_button = `<div></div>`

    `<div className="liveblog">
      <h3>{this.props.name} Live Blog</h3>
      <div className="messages">
        {messages}
        {more_button}
      </div>
    </div>`
