Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  get ':user', to: 'tasks#index'
  get ':user/list', to: 'tasks#list'
end