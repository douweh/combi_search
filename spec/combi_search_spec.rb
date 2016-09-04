require 'spec_helper'
require 'dummy_models'

describe "CombiSearch" do
  before(:all) {
    Book.create_table
    Movie.create_table
    CombiSearch.create_table
  }
  after(:all) {
    Book.drop_table
    Movie.drop_table
    CombiSearch.drop_table
  }

  it 'has a version number' do
    expect(CombiSearch::VERSION).not_to be nil
  end

  it 'calls update_search_entries when creating model' do
    expect_any_instance_of(Movie).to receive(:update_search_entries)
    Movie.create(:title => 'My Movie')
  end

  it 'calls update_search_entries when saving model' do
    movie = Movie.new(:title => 'My Movie')
    expect(movie).to receive(:update_search_entries)
    movie.save
  end

  it 'calls update_search_entries when re-saving model' do
    movie = Movie.new(:title => 'My Movie')
    movie.save
    expect(movie).to receive(:update_search_entries)
    movie.title = "New title"
    movie.save
  end

  describe "SearchEntries" do

    before(:each) {
      CombiSearch::Entry.destroy_all
    }

    it 'are created when a combi-searchable model is created' do
      # Each model has two combi_searsch_scope's defined
      Movie.create()
      expect(CombiSearch::Entry.all.count).to be 2
    end

    it 'are deleted when a combi-searchable model is removed' do
      # Each model has two combi_searsch_scope's defined
      movie = Movie.create()
      book = Book.create()
      expect(CombiSearch::Entry.all.count).to be 4

      movie.destroy
      expect(CombiSearch::Entry.all.count).to be 2
    end
  end

end
