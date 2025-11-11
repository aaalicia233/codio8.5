require 'spec_helper' 
require 'rails_helper'

describe Movie do
  describe 'searching Tmdb by keyword' do
    it 'calls Tmdb with valid parameters and returns movie objects' do
      results = Movie.find_in_tmdb({title: "Olympics", language: "en", release_year: "2000"})

      expect(results).to be_an(Array)

      expect(results.length).to eq(2)

      expect(results.first).to be_a(Movie)
      expect(results.first.title).to eq("Sydney 2000 Olympics Opening Ceremony")
      expect(results.first.rating).to eq("R") # 检查硬编码的 'R'
    end
  end
end