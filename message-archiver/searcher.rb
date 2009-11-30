require 'rubygems'
require 'sinatra/base'

require 'haml'

require 'models'
Models.setup

class Searcher < Sinatra::Base
  set :app_file, File.dirname(__FILE__)
  set :static, true

  before do
    @messages = Groonga::Context.default["messages"]
  end

  get "/" do
    @messages = @messages.sort([["date", :descending]])
    haml :index
  end

  get "/:id" do |id|
    @message = Groonga::Record.new(@messages, Integer(id))
    haml :show
  end

  get "/search/" do
    @query = params[:query]
    @messages = @messages.select do |record|
      record["text"].match(@query)
    end
    haml :search
  end

  private
  def highlight(text)
    query = params[:query]
    return html_escape(text) if query.nil?

    expression_builder = Groonga::RecordExpressionBuilder.new(@messages, nil)
    expression_builder.query = query
    expression_builder.default_column = "text"
    expression = expression_builder.build
    _snippet = expression.snippet([["<span class=\"keyword\">", "</span>"]],
                                  :width => text.size,
                                  :html_escape => true,
                                  :normalize => true)
    segments = _snippet.execute(text)
    if segments.empty?
      html_escape(text)
    else
      segments.join
    end
  end

  def snippet(record)
    expression = record.table.expression
    _snippet = expression.snippet([["<span class=\"keyword\">", "</span>"]],
                                  :width => 100,
                                  :html_escape => true,
                                  :normalize => true)
    separator = "\n<span class='separator'>...</span>\n"
    _snippet.execute(record["text"]).join(separator)
  end
end
