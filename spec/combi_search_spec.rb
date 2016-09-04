require 'spec_helper'
require 'dummy_models'

describe "CombiSearch without setup" do
  before(:all) {
    Book.create_table
  }
  after(:all) {
    Book.drop_table
  }

  it "should throw an exception when trying to save a model, when 'combi_search_entries'-table doesn't exist" do
    expect {
      Book.create
    }.to raise_error("Could not find table 'combi_search_entries'")
  end
end

describe "CombiSearch with setup" do
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

    it 'are updated (not re-inserted) when a combi-searchable model is updated' do
      # Each model has two combi_searsch_scope's defined
      movie = Movie.create()
      expect(CombiSearch::Entry.all.count).to be 2
      movie.title = "New title"
      movie.save
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

  describe "scope" do

    before(:each) {
      CombiSearch::Entry.destroy_all
    }

    it 'returns all the search-entries for a valid scope' do
      Movie.create(:title=>"Irrelevant")
      Movie.create(:title=>"Also irrelevant")
      expect(CombiSearch.scoped(:titles).all.count).to be 2
    end

    it "includes the 'searchable' model for each entry" do
      Movie.create(:title=>"Movie Title")
      Book.create(:title=>"Book Title")
      search_results = CombiSearch.scoped(:titles).all
      expect(search_results.first.searchable.title).to eq "Movie Title"
      expect(search_results.last.searchable.title).to eq "Book Title"
      expect(search_results.first.searchable.class).to be Movie
      expect(search_results.last.searchable.class).to be Book
    end

    xit 'throws for an invalid scope' do
      Movie.create(:title=>"Irrelevant")
      Movie.create(:title=>"Also irrelevant")
      expect(CombiSearch.scoped(:nonexistent).all.count).to be 0
    end

  end

end
