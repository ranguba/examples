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

  get "/search/" do
    @query = params[:query]
    @mails = @mails.select do |record|
      record["body"].match(@query)
    end
    haml :search
  end

  private
  def highlight(body)
    query = params[:query]
    return html_escape(body) if query.nil?

    expression_builder = Groonga::RecordExpressionBuilder.new(@mails, nil)
    expression_builder.query = query
    expression_builder.default_column = "body"
    expression = expression_builder.build
    _snippet = expression.snippet([["<span class=\"keyword\">", "</span>"]],
                                  :width => body.size,
                                  :html_escape => true,
                                  :normalize => true)
    segments = _snippet.execute(body)
    if segments.empty?
      html_escape(body)
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
    _snippet.execute(record["body"]).join(separator)
  end
end
