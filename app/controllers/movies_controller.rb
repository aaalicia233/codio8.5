class MoviesController < ApplicationController
  # 这些是TDD作业开始时就应该存在的标准方法
  def index
    # These 3 lines are the patch to stop the view from crashing
    @all_ratings = Movie.all_ratings
    @ratings_to_show_hash = {}
    @sort_by = nil
  
    # This is the original line for this assignment
    @movies = Movie.all
  end

  def show
    id = params[:id]
    @movie = Movie.find(id)
  end

  def new
    # 默认: 渲染 'new' 模板
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  # --- 这是我们正在TDD的方法 ---
  def search_tmdb
    search_params = params["search"] || {} # 使用字符串键

    if search_params["title"].blank? # 使用字符串键
      flash.now[:warning] = "Please fill in all required fields!"
      @movies = []
    else
      @movies = Movie.find_in_tmdb(search_params)
      if @movies.empty?
        flash.now[:warning] = "No movies found with given parameters!"
      end
    end
  end


  # --- 把这个新方法粘贴在这里 ---
  def add_movie
    # 1. 使用 strong parameters (movie_params) 来安全地创建电影
    #    '.save' 会返回 true/false
    @movie = Movie.new(movie_params)

    if @movie.save
      # 2. 设置 flash 消息 (匹配我们的测试)
      flash[:success] = "'#{@movie.title}' was successfully added to RottenPotatoes."

      # 3. 重定向到主页 (匹配我们的测试)
      redirect_to movies_path
    else
      # 如果保存失败 (例如，如果未来添加了验证)
      flash[:warning] = "Failed to add movie."
      redirect_to search_tmdb_path # 重定向回搜索页
    end
  end

private
# ...

  private
  # 确保 movie_params 存在
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end