Rain::Application.routes.draw do

  get "monthly/monthly"

  get "pages/home"


  resources :yearly_targets

  resources :monthly_targets

  resources :targets

  resources :store_maps

  devise_for :users

	devise_scope :user do
  	resources :users
  end

  get "stock/index"

  get "model/new"

  get "model/index"

  get "laporan_cabang/index"
  get "laporan_cabang/comparison_by_year"
  get "laporan_cabang/control_branches_sales"
  get "laporan_cabang/group_by_cabang"
  get "laporan_cabang/group_by_category"
  get "laporan_cabang/group_by_customer"
  get "laporan_cabang/group_by_type"
  get "laporan_cabang/group_by_merk"
  get "laporan_cabang/group_by_merk_size"
  get "laporan_cabang/group_by_merk_customer"
  get "laporan_cabang/group_by_merk_type"
  get "laporan_cabang/group_categories_comparison"
  get "laporan_cabang/group_category_customer_comparison"
  get "laporan_cabang/group_category_type_comparison"
  get "laporan_cabang/group_category_size_comparison"
  get "laporan_cabang/monthly_comparison"
  get "laporan_cabang/monthly_category_comparison"
  get "laporan_cabang/monthly_type_comparison"
  get "laporan_cabang/monthly_customer_comparison"
	get "laporan_cabang/weekly_report"
	get "laporan_cabang/chart"
	get "stock/special_size"
  get 'stock/update_kategori', :as => 'update_kategori'
  get 'stock/update_jenis_produk', :as => 'update_jenis_produk'
  get 'stock/update_artikel', :as => 'update_artikel'

	authenticated :user do
		root :to => "laporan_cabang#chart"
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
  # just remember to delete public/index.html
  root :to => 'pages', :action => 'home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
