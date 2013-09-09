Rain::Application.routes.draw do

  resources :sales_imports

  get "report_imports/new"

  get "report_imports/create"

  resources :monthly_retails

  get "targets/monthly_target_type"

  get "targets/monthly_target_channel"

  get "targets/monthly_target_customer"

  get "reports/size_special"
	get "reports/size_standard"
  get "reports/customer_modern"
  get "reports/customer_retail"
  get "reports/first_filter"
  get "reports/second_filter"
  get "reports/third_filter"
  get "reports/compare_type"
  get "reports/compare_last_month"
  get "reports/compare_last_year"
  get "reports/compare_current_year"
  get "reports/through"
  get "reports/modern_market"
  get "reports/group"
	get "reports/group_compare"
	get "reports/group_last_month"
	get "reports/quick_view"
	get "reports/quick_view_report"
	get "reports/quick_view_monthly"
	get "reports/quick_view_monthly_process"
	get "reports/quick_view_monthly_result"

  resources :users_mails

  get "users_mails/cofiguration_email"

  get "cabang_so/index"

  get "monthly/monthly"

  get "pages/home"

	#resources :reports
	#get "reports/type"
	get "reports/detail"
	get "reports/standard"
	#get "reports/index"
	resources :user_steps
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
  get "laporan_cabang/customer_by_store"
  get "laporan_cabang/customer_last_month"
  get "laporan_cabang/customer_last_year"
  get "laporan_cabang/customer_monthly"
	get "laporan_cabang/weekly_report"
	get "laporan_cabang/search"
	get "laporan_cabang/search_detail"
	get "laporan_cabang/chart"
	get "stock/special_size"
  get 'stock/update_kategori', :as => 'update_kategori'
  get 'stock/update_jenis_produk', :as => 'update_jenis_produk'
  get 'stock/update_artikel', :as => 'update_artikel'
	get 'reports/update_reports_kain', :as => 'update_reports_kain'
	get 'reports/update_reports_article', :as => 'update_reports_article'
	get 'reports/update_reports_type', :as => 'update_reports_type'
	get 'laporan_cabang/update_kain', :as => 'update_kain'
	get 'laporan_cabang/update_article', :as => 'update_article'


	#authenticated :user do
	#	root :to => "laporan_cabang#chart"
	#end

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
