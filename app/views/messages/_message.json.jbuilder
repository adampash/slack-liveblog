json.id message.id
json.text message.text
json.cursor message.cursor
json.user do
  json.partial! 'users/user', user: message.user
end
json.timestamp message.timestamp
if message.attachment?
  json.attachment message.attachment.url(:large)
  json.original message.attachment.url(:original)
  json.attachment_name message.attachment_file_name
end
unless message.embed.nil?
  json.embed do
    json.partial! 'embeds/embed', embed: message.embed
  end
end
