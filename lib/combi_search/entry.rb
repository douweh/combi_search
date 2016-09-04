module CombiSearch
  class Entry < ActiveRecord::Base
    self.table_name = 'combi_search_entries'
    belongs_to :searchable, :polymorphic => true
  end
end
