Rails.application.routes.draw do
  #共通ログイン(管理課・親方・現場職)
  resources :login ,:only=>[] do
    collection {
      get :login,:logout,:remind,:reminded
      post :login_attempt,:answer,:reset_password
    }
  end


  #管理者用
  namespace :manager do
    get 'error' => 'home#error'
    resources :home ,:only=>[] do
      # collection { get :menu,:error,:destroy_job_err,:mk_test_vacation,:mk_test_lunch_order}
      collection { get :dev,:menu,:error,:destroy_job_err,:ck_job,:mk_test_vacation,:mk_test_lunch_order,:test_calc_work_time}
    end
    #マスタ関連
    resources :users,:user_auths,:lunch_vendors,:lunch_menus,:lunch_locations,:applicables,:branches,
      :wokers,:machines,:machine_maintenances,:board_categories,:vacation_types,
      :cargo_masters,:cargo_requests,:cargo_class_masters,:cargo_cd_masters do
      collection do
        get :csv_in,:csv_output
        post :csv_input
      end
    end
    resources :wh_calendars, :only=>[:index,:update,:show] do 
      collection do
        get :test
      end
    end
    resources :boards
    resources :o_boards,:only=>[:index,:update,:show] do
      member do
        get :file_output
      end
    end

    resources :board_groups do 
      member do
        get :get_target_users
      end
    end
    resources :board_comments, :only=>[:create,:update]
    resources :board_group_wokers, :only=>[:edit,:update,:show]
    resources :lunch_orders, :only=>[:index,:create,:edit,:update]
    resources :lunch_summary, :only=>[:index] do
      collection {get :excel_output}
    end
    resources :vacations do
      collection do
        get :test_run
        post :update_all,:base6_lock,:base6_unlock
      end
    end
    resources :cargos,:only=>[:index,:create,:update]
    resources :wk_assignment,:result_assignment,:only=>[:index,:create,:update] do
      collection do
        post :set_competence,:set_msg,:lock
      end
    end
    resources :delayed_jobs, :only=>[:show]
    resources :print_files,:only=>[:create]
    resources :external_datas,:only=>[] do 
      collection do
        get :csv_in
        post :csv_input
      end
    end
  end

  #共通
  concern :user_editable do
    resources :users, only: [] do
      collection do
        get 'edit'
        put 'update_setting', to: 'users#update_setting'
        put 'update_password', to: 'users#update_password'
      end
    end
  end

  #親方用
  namespace :bos do
    get 'error' => 'home#error'
    concerns :user_editable
    resources :work_schedule,:only=>[:index]
    resources :lunch_orders, :only=>[:index,:create,:edit,:update]
    resources :boards,:only=>[:index,:show] do
      member do
        get :file_output
      end
    end
    resources :board_comments, :only=>[:create,:update]
    # resources :wk_assignment,:only=>[:index,:create,:update] do
    #   collection do
    #     post :set_competence,:set_msg,:lock
    #   end
    # end
    resources :vacations do
      collection do
        post :update_all,:base6_lock,:base6_unlock
      end
    end
    resources :home ,:only=>[] do
      collection { get :menu,:error}
    end
    put "board-targets",:controller=>"/worker_common/board_targets",:action=>:update
    # 20240910
    resources :cargo_requests do
      collection do
        get :csv_in,:csv_output
        post :csv_input
      end
    end
    resources :wk_assignment,:result_assignment,:only=>[:index,:create,:update] do
      collection do
        post :set_competence,:set_msg,:lock
      end
    end
    resources :delayed_jobs, :only=>[:show]
    resources :cargos,:only=>[:index,:create,:update]
    resources :print_files,:only=>[:create]
    resources :lunch_order,:only=>[:edit,:update] do
      collection do
        get :history
      end
    end
    resources :my_vacations 
    resources :m_boards
    resources :board_groups do 
      member do
        get :get_target_users
      end
    end
    resources :lunch_summary, :only=>[:index] do
      collection {get :excel_output}
    end
    resources :external_datas,:only=>[] do 
      collection do
        get :csv_in
        post :csv_input
      end
    end

    
  end

  
  #現業職用
  namespace :operator do
    get 'error' => 'home#error'
    concerns :user_editable
    resources :home ,:only=>[] do
      collection { get :menu,:error}
    end
    resources :work_schedule,:only=>[:index]
    resources :lunch_order,:only=>[:edit,:update] do 
      collection do
        get :history
      end
    end
    resources :boards,:only=>[:index,:update,:show] do
      member do
        get :file_output
      end
    end
    resources :my_vacations 
    put "board-targets",:controller=>"/worker_common/board_targets",:action=>:update
    resources :print_files,:only=>[:create]
  end

  # 事務職用
  namespace :officeworker do
    concerns :user_editable
    get 'error' => 'home#error'
    resources :home ,:only=>[] do
      collection { get :menu,:error}
    end
    resources :cargo_requests do
      collection do
        get :csv_in,:csv_output
        post :csv_input
      end
    end
    resources :lunch_orders, :only=>[:index,:create,:edit,:update]
    resources :print_files,:only=>[:create]
    resources :wk_assignment,:result_assignment,:only=>[:index,:create,:update] do
      collection do
        post :set_competence,:set_msg,:lock
      end
    end
    resources :delayed_jobs, :only=>[:show]
    resources :cargos,:only=>[:index,:create,:update]
    resources :boards,:only=>[:index,:show] do
      member do
        get :file_output
      end
    end
    resources :board_comments, :only=>[:create,:update]
    resources :m_boards
    resources :board_groups do 
      member do
        get :get_target_users
      end
    end

    resources :vacations do
      collection do
        post :update_all,:base6_lock,:base6_unlock
      end
    end

    resources :lunch_summary, :only=>[:index] do
      collection {get :excel_output}
    end
    resources :external_datas,:only=>[] do 
      collection do
        get :csv_in
        post :csv_input
      end
    end


  end
  #App監視
  resources :keeper_ck ,:only=>[:index]
  #バッチ
  namespace :batch do
    resources :clean_up,:work_time_aggregate,:only=>[:index]
  end
  #開発用デモメニュー
  resources :dev_menu ,:only=>[:index,:create]
  if Rails.env.development? || Rails.env.test?
    root :to => 'dev_menu#index'
  else
    root :to => 'login#login'
  end
  unless Rails.application.config.consider_all_requests_local
    get '*path' => 'application#render_404'
  end

end
