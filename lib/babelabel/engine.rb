require "babelabel"
require "rails"

module Babelabel
  class Engine < Rails::Engine
    initializer "babelabel.static_assets" do |app|
      app.middleware.insert_before ::Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

    initializer "babelabel.replace_i18n_backend", :after => :build_middleware_stack do |app|
      if defined?(MongoMapper)
        collection = MongoMapper.database.collection('i18n')
      else
        puts "Couldn't find a connection."
        # collection = Mongo::Connection.new['babelabel-test'].collection('i18n')
      end

      mongo_backend = Babelabel::MongoBackend.new(collection)
      mongo_writeback = Babelabel::MongoWriteback.new(collection)

      backends = [I18n.backend, mongo_backend]
      backends << mongo_writeback if true

      I18n.backend = I18n::Backend::Chain.new(*backends)
      I18n.backend.reload!
    end
  end
end