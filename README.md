# CombiSearch

Use CombiSearch to add a 'global' search to your app. For example; if you have `Book`s and `Movie`s and you want a combined search where you search in all of your titles.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'combi_search'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install combi_search

## Usage
#### 1. Add the _internal_ CombiSearch-Entry model to your database-schema
This model is used to store your 'combined' search data. You can create it by running the following command in your rails console

	CombiSearch.create_table

The best way to add it to a rails project however, is to create a migration for it...
That migration could look like this.

```ruby
class CreateCombiSearchEntries < ActiveRecord::Migration
  def self.up
    say_with_time("Creating table for combi_search_entries") do
      CombiSearch.create_table
    end
  end

  def self.down
    say_with_time("Dropping table for combi_search_entries") do
      CombiSearch.drop_table
    end
  end
end
```

#### 2. Add `combi_search_scope`'s to your models
For every model you want to include in your global search you should call `combi_search_scope` with the name of the scope, the model's `attributes` you want to include for that scope, and an optional `if` condition.

Say you have a `Book` and a `Movie` model, and you want to search either on their titles, or all their text-contents; then your setup should look like this.

```ruby
class Book < ActiveRecord::Base
  include CombiSearch
  combi_search_scope :titles, on: [:title]
  combi_search_scope :full_text, on: [:title, :author, :content]
end

class Movie < ActiveRecord::Base
  include CombiSearch
  combi_search_scope :titles, on: [:title]
  combi_search_scope :full_text, on: [:title, :director, :script_content]
end 
```

If you only want to include `published` books, when you search in the titles scope, then you should change your code like this.

```ruby
  combi_search_scope :titles, on: => [:title], if: lambda { |book| book.published }
```

#### 3. Create your search index
The search-index gets updated once your model is updated. To make sure your search-index is up-to-date when you add it for pre-existing models, you can run the following in your console:

	# delete existing index
	CombiSearch.remove_index
	
	# Create index for Book's
	Book.update_combi_search
	
	# Create index for Movie's
	Movie.update_combi_search

The best way _again_ to do this for your rails project, is to create a migration for it...
That migration could look like this.

```ruby
class CreateCombiSearchEntries < ActiveRecord::Migration
  def self.up
    say_with_time("Updating search index") do
      CombiSearch.remove_index
      Book.update_combi_search
      Movie.update_combi_search
    end
  end

  def self.down
    # there isn't a down migration for this....
  end
end
```

#### 4. That's it: search for it!
To find all Book's and Movie's where the `:titles` includes Harry Potter:

	library_items = CombiSearch.scoped(:titles).search("Harry Potter")
	
To find all Book's and Movie's where the `:full_text` includes "Abacadabra":

	library_items = CombiSearch.scoped(:full_text).search("Abacadabra")
	
This returns an `ActiveRecord::Relation` of `CombiSearch::Entry` models. They are not that interesting.... however they have a relation to an included `searchable` model which is the original (`Book` or `Movie`) model.

The following code:

```ruby
	library_items = CombiSearch.scoped(:titles).search("Harry Potter")
	
	library_items.each { |item| 
		original = item.searchable
		if original.is_a?(Book)
			puts "We found a Book; and the title is: #{original.title}"
		end
		if original.is_a?(Movie)
			puts "We found a Movie; and the director is: #{original.director}"
		end
	}
```

Could output something like:
	
	We found a Movie; and the director is: Chris Columbus
	We found a Book; and the title is: Harry Potter and the Sorcerer's Stone

## Development

After checking out the repo, run `bundle exec rspec spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/douweh/combi_search/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
