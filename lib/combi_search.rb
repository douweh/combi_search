require "active_support"

require "combi_search/version"
require "combi_search/entry"
require "combi_search/migration"

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
    existing_entries_hash = {}
    search_entries.pluck(:id, :scope).each { |result|
      existing_entries_hash[result[1].to_sym] = result[0]
    }
    search_scopes.each { |scope, array_with_configs|

      # loop over all configs, to determine our searchable_text, if any...
      search_entry_should_exist = false
      searchable_text = ""

      array_with_configs.each { |option|

        # if an :if condition was defined, test it
        if option[:if] && option[:if].is_a?(Proc)
          if_condition_matched = option[:if].call(self)

          # if this condition matched, we should use the text defined in this configuration
          if if_condition_matched
            search_entry_should_exist = true
            searchable_text = search_string_for_attrs(option[:on])
          end

          # if there was no 'if' condition, then we shouldn't test for it,
          # we should use the text defined in this configuration
        else
          search_entry_should_exist = true
          searchable_text = search_string_for_attrs(option[:on])
        end
      }

      # if we found a matching config (either with if-condition or not), create or update the entry
      if search_entry_should_exist
        # pre existing search_entry
        id = existing_entries_hash[scope]
        if !id.nil?
          search_entries.update(id, :content=>searchable_text)
          existing_entries_hash.delete(scope)
        else
          search_entries.create(:scope=>scope, :content=>searchable_text)
        end
      end
    }

    # add this point all pre_existing_entries should be updated and removed from the hash
    # when there are still entries in the hash it means that 'scope' got removed in code
    # therefore we should remove it's search_entry from the database
    remove_ids = existing_entries_hash.each { |scope, id|
      search_entries.delete(id)
    }
  end

  module ClassMethods

    # Method to add a combi_search_scope for a specific model
    # Usage:
    #   combi_search_scope :public, on: [:name, :title, :something_else]
    def combi_search_scope(name, options = {})
      if options.nil? || options[:on].nil? || !(options[:on].class == Symbol || options[:on].class == Array)
        raise "No attributes defined for combi_search_scope: #{:name}, in: #{self}"
      end

      if !self.combi_search_scopes[name].is_a?(Array)
        self.combi_search_scopes[name]=[]
      end
      self.combi_search_scopes[name].push(options)
    end

    def update_combi_search
      self.all.each { |model|
        model.update_search_entries
      }
    end

  end


  ## MODULE METHODS

  def self.scoped(scope)
    CombiSearch::Entry.where(:scope=>scope).includes(:searchable)
  end

  def self.remove_index
    CombiSearch::Entry.destroy_all
  end


end
