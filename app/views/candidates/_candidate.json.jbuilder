json.extract! candidate, :id, :name, :poll, :created_at, :updated_at
json.url candidate_url(candidate, format: :json)