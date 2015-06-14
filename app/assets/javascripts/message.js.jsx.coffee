@Message = React.createClass
  formatTimestamp: ->
    moment(@props.data.timestamp).format("h:mm A")
  render: ->
    timestamp = @formatTimestamp()
    if @props.data.attachment?
      payload = `<img src={this.props.data.attachment} />`
    else
      payload = @props.data.text
    return `<div></div>` if @props.data.user.name is 'slackbot'

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
        </div>
      </div>`
