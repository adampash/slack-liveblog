emoji.img_sets.apple.path = "//gawker-labs.com/emoji/img-apple-64/"
emoji.img_sets.apple.sheet = "//gawker-labs.com/emoji/sheet_apple_20.png"

fluidvids.init
  selector: ['.fluidvid'], # runs querySelectorAll()
  players: ['www.youtube.com', 'player.vimeo.com'] # players to support

@Unfurl =
  all: (@text) ->
    if @hasLinks(@text)
      @extractLinks()
      # @fluidvids()

    @emojify()
    @text

  linkRe: /<(.+\|?.*)>/

  linkObjRe: /<((.+)\|?(.*))>/

  hasLinks: ->
    @text.match(@linkRe)?

  extractLinks: ->
    link_match = @text.match(@linkObjRe)
    link =
      url: link_match[2]
      text: link_match[3]

  emojify: ->
    emoji.init_env()
    emoji.supports_css = false
    @text = emoji.replace_colons(@text)

  fluidvids:->
    if @text.match(/\bhttps?:\/\/(www\.)?youtube.com/)
      console.log "it's got a vid"
