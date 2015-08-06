require 'opengraph_parser'

class Embed < ActiveRecord::Base
  belongs_to :message

  def self.create_from_message(message_id)
    message = Message.find message_id
    link = extract_link(message.text)
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    begin
      html = agent.get(link[:url]).content
      unless html.is_a? StringIO
        og = OpenGraph.new(html)
        type = og.type.nil? ? '' : og.type.downcase
        create(
          message_id: message.id,
          description: og.description,
          og_type: type,
          title: og.title,
          url: og.url,
          image: og.images.first,
        )
      end
    rescue
      puts $!.message
    end
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

  def self.create_from_attachment(message, data)
    link = extract_link(data["pretext"])
    create(
      message_id: message.id,
      description: data["text"],
      og_type: 'article',
      title: data["author_name"],
      url: link,
      image: data["author_icon"],
    )
  end

end
