require 'rubygems'
require 'sinatra/base'

require 'haml'

require 'models'
Models.setup

class Searcher < Sinatra::Base
  set :app_file, File.dirname(__FILE__)
  set :static, true

  get "/" do
    haml :index
  end
end
