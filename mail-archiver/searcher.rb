require 'rubygems'
require 'sinatra/base'

require 'haml'

class Searcher < Sinatra::Base
  set :app_file, File.dirname(__FILE__)
  set :static, true

  get "/" do
    haml :index
  end
end
