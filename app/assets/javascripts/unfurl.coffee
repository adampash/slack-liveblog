emoji.img_sets.apple.path = "//gawker-labs.com/emoji/img-apple-64/"
emoji.img_sets.apple.sheet = "//gawker-labs.com/emoji/sheet_apple_20.png"

@Unfurl =
  all: (text) ->
    @emojify(text)


  emojify: (text) ->
    emoji.init_env()
    emoji.supports_css = false
    emoji.replace_colons(text)
