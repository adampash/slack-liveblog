@User = React.createClass
  render: ->
    `<div>
      <img src={this.props.data.avatar} />
      <div className="username">
        {this.props.data.name}
      </div>
    </div>`
