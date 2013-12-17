#07-2013 Migration in Ruby On Rails  3.2 by Benjamin Ninassi
OscNew::Application.routes.draw do


  root :to => "contrats#index"
  
  resources :accounts
  
  resources :budgetaire_references do
    member do
      get :ask_delete
    end
  end
    
  resources :contrats do
    member do
      get :ask_delete
      get :show_not_authorized_users
      get :show_not_authorized_groups
      get :reporting
      post :add_user
      post :add_group
      post :delete_user
      post :delete_group
      post :duplicate
    end
    collection do
      get :my_last_search
      get :search
    end
    resources :todolists do
      member do
        post :update_positions
        get :ask_delete
      end
      resources :todoitems do
        member do
          post :undone
          post :done
          post :update_positions
          get :ask_delete
        end
      end
    end
    resources :signatures do
      member do
        get :ask_delete
      end    
    end
    resources :soumissions do
      member do
        get :ask_delete
        get :getpdf
      end
      collection do
        get :update_type_contrat
      end
    end
    resources :refus do
      member do
        get :ask_delete
      end
    end
    resources :notifications do
      member do
        get :ask_delete
      end
      collection do
        get :update_type_contrat
      end
    end
    resources :clotures do
      member do
        get :ask_delete
      end
    end
    resources :echeanciers do
      member do
        get :ask_delete
      end
    end
    resources :contrat_files do
      member do
        get :edit_description
        put :update_description
        get :ask_delete
      end
      collection do
        post :sort_by
      end
    end
    resources :descriptifs do
      member do
        get :ask_delete
      end
    end
  end
  
  resources :contrat_types do
    member do
      get :ask_delete
    end
  end
  resources :departements do
    member do
      get :ask_delete
    end
  end
  resources :departement_subscriptions do
    member do
      post :create
    end
  end
  resources :groups do
    member do
      post :delete_droit
      post :delete_role
      get :ask_delete
    end
    collection do 
      get :search_by_name
    end
  end
  
  resources :key_words do
    member do
      get :ask_delete
    end
   
    collection do
      post :sort_by
    end
  end
  
  resources :laboratoires do
    member do
      get :ask_delete
    end
  end
  resources :laboratoire_subscriptions do
    member do
      post :create
    end
  end
  resources :lignes do
    collection do
      get :search
      get :search_in_create
      get :my_last_search
      post :toggle_show_justification_data_preferences
    end
    member do
      get :ask_delete
      get :ask_desactivate
      get :bilan
      post :desactivate
      post :activate
    end
    resources :versements do
      member do
        get :ask_delete
        post :duplicate
        get :build_migration_form
      end
    end
    resources :depense_fonctionnements do
      member do
        get :ask_delete
        post :duplicate
        get :build_migration_form
      end
    end
    resources :depense_equipements do
      member do
        get :ask_delete
        post :duplicate
        get :build_migration_form
      end
    end
    resources :depense_missions do
      member do
        get :ask_delete
        post :duplicate
        get :build_migration_form
      end
    end
    resources :depense_salaires do
      member do
        get :ask_delete
        post :duplicate
        get :build_migration_form
      end
      collection do
        post :search_people_from_ose
        post :search_people_from_gef
        get :create_salaires_from_gef
      end
    end
    resources :depense_non_ventilees do
      member do
        get :ask_delete
        post :duplicate
        get :build_migration_form
      end
    end
    resources :depense_communs do
      member do
        get :ask_delete
        post :duplicate
        get :build_migration_form
      end
    end
  end

  resources :memberships

  resources :organisme_gestionnaires do
    member do
      get :ask_delete
    end
    resources :organisme_gestionnaires_tauxes
  end

  resources :projets do
    member do
      get :ask_delete
    end
    collection do 
      get :search_by_name
    end
  end
  resources  :rubrique_comptables do
    member do
      get :ask_delete
    end
  end
  resources :sous_contrats do
    member do
      get :ask_delete
    end
  end
  resources :tutelles do 
    member do
      get :ask_delete
    end
  end
  resources :tutelle_logos
  resources :tutelle_subscriptions do
    member do
      post :create
    end
  end

  resources :users do
    collection do 
      get :search_by_name
    end
    member do
      post :delete_droit
      post :delete_role
      get :ask_delete
    end
    resources :user_images
  end
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end
