module CombiSearch
  def self.create_table
    ActiveRecord::Base.connection.create_table :combi_search_entries do |t|
      t.text :content
      t.text :scope
      t.belongs_to :searchable, :polymorphic => true
      t.timestamps
    end
  end

  def self.drop_table
    ActiveRecord::Base.connection.drop_table :combi_search_entries
  end
end
