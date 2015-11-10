json.id message.id
json.text message.text
json.cursor message.cursor
json.processed message.processed
json.user do
  json.partial! 'users/user', user: message.user
end
json.timestamp message.timestamp
if message.attachment?
  json.attachment do
    # json.url message.attachment.url(:large)
    # json.url message.attachment.url(:original)
    json.url message.attachment_url
    json.name message.attachment_file_name
  end
end
unless message.embed.nil?
  json.embed do
    json.partial! 'embeds/embed', embed: message.embed
  end
end
