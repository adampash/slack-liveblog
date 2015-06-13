@LiveBlog = React.createClass
  getInitialState: ->
    messages: @props.messages,
    live: @props.live,

  timer: null

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
        messages = @state.messages
        messages = _.uniq(response.concat messages)
        @setState
          messages: messages
      error: (e) =>
        console.warn "ERROR"
        @
        debugger

  render: ->
    messages = @state.messages.map (message, index) =>
      `<Message data={message} key={message.id} />`
    `<div>
      <h3>{this.props.name} Live Blog</h3>
      <div className="messages">
        {messages}
      </div>
    </div>`
