json.extract! vote, :id, :voter, :candidate, :poll, :priority, :created_at, :updated_at
json.url vote_url(vote, format: :json)