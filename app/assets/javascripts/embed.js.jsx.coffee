@Embed = React.createClass
  getInitialState: ->
    play: true

  isYouTube: ->
    @props.data.url.match(/^https?:\/\/(www\.)?youtube.com/)?
  getYoutubeId: ->
    @props.data.url.match(/v=(\w+)$/)[1]

  componentDidMount: ->
    # fluidvids.render() if @props.data.type is 'video'

  playVid: ->
    @setState
      play: true

  render: ->
    data = @props.data
    if data.type is 'article'
      if data.image?
        img = `<img src={data.image} />`
      embed = `<div className="embed article">
        {img}
        <div className="content">
          <a href={data.url} target="_blank">
            <h4>{data.title}</h4>
          </a>
          <div className="description">
            {data.description}
          </div>
        </div>
      </div>`
    else if data.type is 'video'
      # if data.image?
      #   img = `<img src={data.image} />`
      if @isYouTube()
        videoId = @getYoutubeId()
        unless @state.play
          embed = `<div className="embed video">
            <div className="vid_thumb" onClick={this.playVid}>
              <img
                src={data.image}
                width="100%"
                height="400px"
              />
            </div>
          </div>`
        else
          embed = `<div className="embed video">
            <iframe
              src={"http://www.youtube.com/embed/" + videoId}
              width="100%"
              height="400px"
            />
          </div>`
      else
        `<div></div>`
    else
      `<div></div>`
