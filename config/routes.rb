Rails.application.routes.draw do
  post 'slack/create_poll'

  post 'slack/close_poll'

  post 'slack/vote'

  post 'slack/see_candidates'

  post 'slack/see_standings'

  post 'slack/see_winner'

  post 'slack/messages'

  get 'slack/messages'

  resources :votes
  resources :candidates
  resources :polls
  get 'create_poll/close_poll'

  get 'create_poll/vote'

  get 'create_poll/see_candidates'

  get 'create_poll/see_standings'



  root 'welcome#index'
end
