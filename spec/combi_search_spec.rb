require 'spec_helper'
require 'dummy_models'

describe "CombiSearch without migrations" do
  before(:all) {
    Book.create_table
  }
  after(:all) {
    Book.drop_table
  }

  it "should throw an exception when trying to save a model when 'combi_search_entries'-table doesn't exist" do
    expect {
      Book.create
    }.to raise_error("Could not find table 'combi_search_entries'")
  end
end

describe CombiSearch do
  before(:all) {
    Book.create_table
    Movie.create_table
    SecretFile.create_table
    CombiSearch.create_table
  }
  after(:all) {
    Book.drop_table
    Movie.drop_table
    SecretFile.drop_table
    CombiSearch.drop_table
  }

  it "calls update_search_entries when creating model" do
    expect_any_instance_of(Movie).to receive(:update_search_entries)
    Movie.create(:title => 'My Movie')
  end

  it "calls update_search_entries when saving model" do
    movie = Movie.new(:title => 'My Movie')
    expect(movie).to receive(:update_search_entries)
    movie.save
  end

  it "calls update_search_entries when re-saving model" do
    movie = Movie.new(:title => 'My Movie')
    movie.save
    expect(movie).to receive(:update_search_entries)
    movie.title = "New title"
    movie.save
  end

  describe CombiSearch::Entry do

    before(:each) {
      CombiSearch::Entry.destroy_all
      Movie.destroy_all
      Book.destroy_all
    }

    it "are created when a combi-searchable model is created" do
      # Each model has two combi_searsch_scope's defined
      Movie.create()
      expect(CombiSearch::Entry.all.count).to be 2
    end

    it "are updated (not re-inserted) when a combi-searchable model is updated" do
      # Each model has two combi_searsch_scope's defined
      movie = Movie.create()
      expect(CombiSearch::Entry.all.count).to be 2
      movie.title = "New title"
      movie.save
      expect(CombiSearch::Entry.all.count).to be 2
    end

    it "are deleted when a combi-searchable model is removed" do
      # Each model has two combi_searsch_scope's defined
      movie = Movie.create()
      book = Book.create()
      expect(CombiSearch::Entry.all.count).to be 4

      movie.destroy
      expect(CombiSearch::Entry.all.count).to be 2
    end

    it "are deleted when a combi-searchable-scope definition is removed from code and model gets update" do
      # Each model has two combi_searsch_scope's defined
      movie = Movie.create()
      expect(CombiSearch::Entry.all.count).to be 2

      # Add bullshit scopes
      movie.search_entries.create(:scope=>"bullshit", :content=>"bullshit")
      movie.search_entries.create(:scope=>"more_bullshit", :content=>"more_bullshit")
      expect(CombiSearch::Entry.all.count).to be 4

      # Updating the model should remove the scopes which are not defined in code
      movie.title= "update"
      movie.save

      expect(CombiSearch::Entry.all.count).to be 2
    end

    it "are created when class-method 'update_combi_search' is called" do
      movie = Movie.create()
      expect(CombiSearch::Entry.all.count).to be 2
      movie = Movie.create()
      expect(CombiSearch::Entry.all.count).to be 4
      movie = Movie.create()
      expect(CombiSearch::Entry.all.count).to be 6

      CombiSearch.remove_index
      expect(CombiSearch::Entry.all.count).to be 0

      Movie.update_combi_search
      expect(CombiSearch::Entry.all.count).to be 6
    end

    it "has the right 'content' based on if condition" do
      # security_level 0 means: 'public' index should have public_title
      # security_level 1 means: 'public' index should have secret_title
      # security_level 2 means: 'public' index should not exist at all (no if-condition matched)

      # SecretFile also has a 'admin' index defined, that should allways exist.

      file = SecretFile.new(:secret_title => 'SuperSecret', :public_title => 'NotSoSecret', :security_level => 0)
      file.save
      expect(CombiSearch::Entry.all.count).to be 2 # public and admin
      expect(CombiSearch::Entry.all.first.content).to eq('NotSoSecret')

      file.update(:security_level => 1)
      expect(CombiSearch::Entry.all.count).to be 2 # public and admin
      expect(CombiSearch::Entry.all.first.content).to eq('SuperSecret')

      file.update(:security_level => 2)
      expect(CombiSearch::Entry.all.count).to be 1 # only admin

    end
  end

  describe ".scope" do

    before(:each) {
      CombiSearch::Entry.destroy_all
    }

    it "returns all the search-entries for a valid scope" do
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

    xit "throws for an invalid scope" do
      expect(CombiSearch.scoped(:nonexistent).all.count).to raise_error("Scope doesn't exist")
    end

  end

  describe ".search" do

    before(:each) {
      Movie.destroy_all
      Book.destroy_all
      CombiSearch::Entry.destroy_all
      Book.create(:title=>"Harry Potter and the Sorcerer's Stone", :author => "JK Rowling")
      Book.create(:title=>"Harry Potter and the Chamber of Secrets", :author => "JK Rowling")
      Book.create(:title=>"Power 10: An Olympian Shares 10 Ways to Improve Your Rowing", :author => "Fred Borchelt")
      Movie.create(:title=>"Harry Potter and the Sorcerer's Stone", :director=>"Chris Columbus")
      Movie.create(:title=>"Harry Potter and the Chamber of Secrets", :director=>"Chris Columbus")
    }

    it "searches full-text within scope" do
      expect(CombiSearch.scoped(:titles).search('potter').all.count).to be(4) # matches all harry potter titles
      expect(CombiSearch.scoped(:titles).search('Pott hArrY').all.count).to be(4) # matches all harry potter titles
      expect(CombiSearch.scoped(:all_text).search('Rowling').all.count).to be(2) # matches all JK Rowling-books
      expect(CombiSearch.scoped(:all_text).search('Row').all.count).to be(3) # matches all JK Rowling-books, AND Rowing titles
    end

  end

end
