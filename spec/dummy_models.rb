require 'combi_search'

class Book < ActiveRecord::Base
  include CombiSearch

  combi_search_scope :titles, on: [:title, :subtitle]
  combi_search_scope :all_text, on: [:title, :subtitle, :author, :content]

  def self.create_table
    ActiveRecord::Base.connection.create_table :books do |t|
      t.string :title
      t.string :subtitle
      t.string :author
      t.string :content
    end
  end

  def self.drop_table
    ActiveRecord::Base.connection.drop_table :books
  end
end

class Movie < ActiveRecord::Base
  include CombiSearch

  combi_search_scope :titles, on: [:title, :subtitle]
  combi_search_scope :all_text, on: [:title, :subtitle, :director, :content]

  def self.create_table
    ActiveRecord::Base.connection.create_table :movies do |t|
      t.string :title
      t.string :subtitle
      t.string :director
      t.string :content
    end
  end

  def self.drop_table
    ActiveRecord::Base.connection.drop_table :movies
  end
end

class SecretFile < ActiveRecord::Base
  include CombiSearch

  combi_search_scope :public, on: [:public_title], if: lambda { |doc| doc.security_level == 0 }
  combi_search_scope :public, on: [:secret_title], if: lambda { |doc| doc.security_level == 1 }
  combi_search_scope :admin, on: [:public_title, :secret_title]

  def self.create_table
    ActiveRecord::Base.connection.create_table :secret_files do |t|
      t.string :public_title
      t.string :secret_title
      t.integer :security_level
    end
  end

  def self.drop_table
    ActiveRecord::Base.connection.drop_table :secret_files
  end
end
