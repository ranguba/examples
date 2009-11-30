require 'rubygems'
require 'sinatra/base'

require 'haml'

require 'models'
Models.setup

class Searcher < Sinatra::Base
  set :app_file, File.dirname(__FILE__)
  set :static, true

  before do
    @mails = Groonga::Context.default["mails"]
  end

  get "/" do
    @mails = @mails.sort([["date", :descending]])
    haml :index
  end

  get "/:id" do |id|
    @mail = Groonga::Record.new(@mails, Integer(id))
    haml :show
  end
end
