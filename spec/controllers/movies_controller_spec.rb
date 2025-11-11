require 'rails_helper'

if RUBY_VERSION>='2.6.0'
  if Rails.version < '5'
    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        # hack to avoid MonitorMixin double-initialize error:
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        initialize
      end
    end
  else
    puts "Monkeypatch for ActionController::TestResponse no longer needed"
  end
end

describe MoviesController do

  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    # --- 这是测试 1 ---
    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with({'title' => 'hardware', 'language' => 'en-US'}).
       and_return(@fake_results)

      # --- 修复：使用 Rails 4 语法 (没有 'params:') ---
      get :search_tmdb, {search: {title: 'hardware', language: 'en-US'}}
    end

    # --- 这是测试 2 和 3 ---
    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)

        # --- 修复：使用 Rails 4 语法 (没有 'params:') ---
        get :search_tmdb, {search: {title: 'hardware', language: 'en-US'}}
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
  end
  describe 'adding a movie' do
    it 'creates a new movie, sets a flash message, and redirects to the home page' do
      # 准备我们将要 POST 的电影参数
      movie_params = { movie: { title: 'New Movie', release_date: '2025-01-01', rating: 'R', description: 'A movie.' } }
  
      # 1. 检查数据库：期望 Movie.count (电影总数) 增加 1
      expect {
        # 使用 Rails 4 语法 (没有 'params:')
        post :add_movie, movie_params
      }.to change(Movie, :count).by(1)
  
      # 2. 检查重定向：期望重定向到主页 (movies_path)
      expect(response).to redirect_to(movies_path)
  
      # 3. 检查 Flash 消息
      expect(flash[:success]).to eq("'New Movie' was successfully added to RottenPotatoes.")
    end
  end
end