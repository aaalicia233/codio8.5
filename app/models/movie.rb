class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end
  def self.find_in_tmdb(search_terms)
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
  def self.find_in_tmdb(search_params, api_key: '58087f4212acff8415de4471a8e44e19')
    # 这是TMDb API的基础URL
    base_url = "https://api.themoviedb.org/3/search/movie"
  
    # 构建查询参数哈希
    query_params = {
      api_key: api_key,
      query: search_params[:title],
      language: search_params[:language] || 'en-US' # 默认为 'en-US'
    }
    # 只有在 release_year 存在时才添加它
    query_params[:year] = search_params[:release_year] if search_params[:release_year].present?
  
    begin
      # Faraday.get 会自动把 query_params 转换成 URL
      # 这个调用会被 spec/spec_helper.rb 里的 WebMock 存根(stub)拦截
      response = Faraday.get(base_url, query_params)
  
      if response.success?
        # 解析 JSON 字符串
        json_results = JSON.parse(response.body)
  
        # "return a list of movies that have NOT been saved"
        # 我们把 JSON 结果数组 转换成 Movie 对象数组
        movies = json_results['results'].map do |movie_data|
          Movie.new(
            title: movie_data['title'],
            release_date: movie_data['release_date'],
            rating: 'R', # "you should just put 'R' for all of them"
            description: movie_data['overview']
          )
        end
        return movies
      else
        return [] # API 报告错误 (例如，错误的 API 密钥)
      end
    rescue Faraday::Error, JSON::ParserError
      return [] # 发生连接错误或 JSON 解析错误
    end
  end
end
