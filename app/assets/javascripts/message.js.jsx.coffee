ImageLoader = ReactImageLoader

@Message = React.createClass
  getInitialState: ->
    fetchTries: 0
    # embed: @props.data.embed
    # processed: @props.data.processed
    # attachment: @props.data.attachment
    # user: @props.data.user

  formatTimestamp: ->
    moment(@props.data.timestamp).format("h:mm A")

  componentDidMount: ->
    unless @props.data.processed
      setTimeout @fetchUnprocessed, 2000

  fetchUnprocessed: ->
    if @state.fetchTries < 10 and !@props.data.processed
      $.ajax
        url: "/messages/#{@props.data.id}.json"
        method: "GET"
        dataType: 'json'
        success: (message) =>
          if message.processed
            console.log message
            console.log message.processed
            @props.updateUnprocessed(message)
            # @setState
            #   embed: message.embed
            #   attachment: message.attachment
            #   processed: true
            #   user: message.user
          else
            @setState
              fetchTries: @state.fetchTries + 1
            setTimeout @fetchUnprocessed, 2000 * @state.fetchTries
        error: =>
          debugger

  handleImageClick: (e) ->
    e.preventDefault()
    window.open(e.currentTarget.href)

  render: ->
    try
      timestamp = @formatTimestamp()
      if @props.data.user.name is 'slackbot'
        hideMessage = "hidden"
      else
        hideMessage = ""
      if @props.data.attachment?.url?
        payload = `<a href={this.props.data.attachment.original} _target="_blank" onClick={this.handleImageClick}>
                    <figure>
                      <ImageLoader
                        src={this.props.data.attachment.url}
                        onLoad={this.props.resize}
                      />
                      <figcaption>
                        {this.props.data.attachment.name}
                      </figcaption>
                    </figure>
                  </a>`
      else
        text = @processText(@props.data.text)
        payload = `<div dangerouslySetInnerHTML={{__html: text}} />`

      if @props.data.embed?
        embed = `<Embed data={this.props.data.embed}
                    resize={this.props.resize}
                />`
        if @props.data.text.match(/^<.+>$/)
          payload = ''
      else
        embed = ''

      if @props.hide
        hideAble = "hide"
      else
        hideAble = ""

      `<div className={"message " + hideAble + " " + hideMessage}>
          <div className="avatar">
            <img src={this.props.data.user.avatar} />
            <div className="alt timestamp">
              {timestamp.split(" ")[0]}
            </div>
          </div>
          <div className="content">
            <div className="user_and_time">
              <div className="username">
                {this.props.data.user.name}
              </div>
              <div className="timestamp">
                {timestamp}
              </div>
            </div>
            <div className="text">
              {payload}
            </div>
            {embed}
          </div>
        </div>`
    catch
      `<div />`

  processText: (text="") ->
    text = Unfurl.all(text)
    text
