module Babelabel
  require 'babelabel/engine' if defined?(Rails)

  autoload :MongoBackend, 'babelabel/mongo_backend'
  autoload :MongoWriteback, 'babelabel/mongo_writeback'
end