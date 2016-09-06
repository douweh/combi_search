require "active_record"
require "search_cop"

module CombiSearch
  class Entry < ActiveRecord::Base
    include SearchCop

    self.table_name = 'combi_search_entries'
    belongs_to :searchable, :polymorphic => true

    search_scope :search do
      attributes :content
    end
  end
end
