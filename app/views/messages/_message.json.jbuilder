json.id message.id
json.text message.text.emojify
json.cursor message.cursor
json.user do
  json.partial! 'users/user', user: message.user
end
json.timestamp message.timestamp
if message.attachment?
  json.attachment message.attachment.url(:large)
end
