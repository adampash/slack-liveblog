require 'opengraph_parser'

class Embed < ActiveRecord::Base
  belongs_to :message

  def self.create_from_message(message_id)
    message = Message.find message_id
    link = extract_link(message.text)
    og = OpenGraph.new(link[:url])
    create(
      message_id: message.id,
      description: og.description,
      og_type: og.type,
      title: og.title,
      url: og.url,
      image: og.images.first,
    )
    message.update_attributes processed: true
  end

  def self.extract_link(text)
    link_obj_re = /<((.+)\|?(.*))>/
    link_match = text.match(link_obj_re)
    {
      url: link_match[2],
      text: link_match[3]
    }
  end

end
