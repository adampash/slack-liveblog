@Message = React.createClass
  render: ->
    if @props.data.attachment?
      payload = `<img src={this.props.data.attachment} />`
    else
      payload = @props.data.text
    `<div>
        <User data={this.props.data.user} />
        <div className="text">
          {payload}
        </div>
      </div>`
