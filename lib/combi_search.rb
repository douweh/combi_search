require "active_support"
require "active_record"

require "combi_search/version"
require "combi_search/entry"

module CombiSearch
  extend ActiveSupport::Concern

  included do

    has_many :search_entries,
             :as => :searchable,
             :class_name => "CombiSearch::Entry",
             :dependent => :delete_all

    # register after_save handler to update search entry
    after_save :update_search_entries

    # register class_attribute combi_search_scopes to store search scopes
    class_attribute :combi_search_scopes
    self.combi_search_scopes = {};
  end

  def search_string_for_attrs(attrs)
    if attrs.class == Array
      return attrs.map { |attr| search_string_for_attrs(attr)}.join("\n")
    end
    if attrs.class == Symbol
      return send(attrs)
    end
  end

  def update_search_entries
    # Retrieve all combi_search_scopes defined for our class
    search_scopes = self.class.combi_search_scopes
    existing_entries = search_entries.pluck(:id, :scope)
    search_scopes.each { |scope, options|
      searchable_text = search_string_for_attrs(options[:on])
      search_entries.create(:scope=>scope, :content=>searchable_text)
    }
    puts existing_entries
  end

  module ClassMethods

    # Method to add a combi_search_scope for a specific model
    # Usage:
    #   combi_search_scope :public, on: [:name, :title, :something_else]
    def combi_search_scope(name, options = {})
      if options.nil? || options[:on].nil? || !(options[:on].class == Symbol || options[:on].class == Array)
        raise "No attributes defined for combi_search_scope: #{:name}, in: #{self}"
      end

      self.combi_search_scopes[name] = options
    end
  end
end
