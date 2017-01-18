json.extract! poll, :id, :name, :open, :created_at, :updated_at
json.url poll_url(poll, format: :json)