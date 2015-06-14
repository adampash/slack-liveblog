ImageLoader = ReactImageLoader

@Message = React.createClass
  formatTimestamp: ->
    moment(@props.data.timestamp).format("h:mm A")

  handleImageClick: (e) ->
    e.preventDefault()
    window.open(e.currentTarget.href)

  render: ->
    timestamp = @formatTimestamp()
    if @props.data.attachment?
      payload = `<a href={this.props.data.original} _target="_blank" onClick={this.handleImageClick}>
                  <figure>
                    <ImageLoader
                      src={this.props.data.attachment}
                      onLoad={this.resize}
                    />
                    <figcaption>
                      {this.props.data.attachment_name}
                    </figcaption>
                  </figure>
                </a>`
    else
      text = @processText(@props.data.text)
      payload = `<div dangerouslySetInnerHTML={{__html: text}} />`
    return `<div></div>` if @props.data.user.name is 'slackbot'

    if @props.data.embed?
      embed = `<Embed data={this.props.data.embed} />`
    else
      embed = ''

    if @props.hide
      hideAble = "hide"
    else
      hideAble = ""

    `<div className={"message " + hideAble}>
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

  processText: (text="") ->
    text = Unfurl.all(text)
    text
