json.id message.id
json.text message.text
json.user do
  json.partial! 'users/user', user: message.user
end
json.timestamp message.timestamp
if message.attachment?
  json.attachment message.attachment.url
end
