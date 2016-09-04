require "active_record"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ActiveRecord::Base.establish_connection(
    adapter:  'sqlite3',
    database: ':memory:'
)
