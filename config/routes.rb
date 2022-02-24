Rails.application.routes.draw do
  resources :booklist_sections
  
	devise_for :users
	root to: "application#index"

  get 'new_title_or_apocryphon', to: 'apocrypha#form_container'

  resources :person_references
  resources :modern_source_references
  resources :source_urls
  resources :modern_sources do
    collection do
      post :create_from_booklist
    end
  end
  resources :sections
  resources :booklist_references
  resources :booklists
  resources :text_urls
  resources :texts
  resources :contents do
    collection do
      put :sort
      post :move_to_booklet
    end
  end
  resources :titles
  resources :apocrypha do
    collection do
      post :create_from_booklist
    end
  end
  resources :ownerships
  resources :people
  resources :booklets do
    collection do
      put :sort
      post :create_from_booklist
    end
  end
  resources :manuscripts do
    collection do
      post :create_from_booklist
    end
    resources :booklets do
      collection do
        post :create_from_booklist
      end
      resources :contents do
        collection do
          post :create_from_booklist
        end
        resources :texts
      end
    end
    resources :contents do
      resources :texts
    end
  end
  resources :language_references
  resources :institutional_affiliations
  resources :religious_orders
  resources :institutions
  resources :languages
  resources :locations

end
