class DocumentsController < ApplicationController
  # GET /documents
  # GET /documents.xml
  def index
    respond_to do |format|
      format.html
      format.xml do
        @documents = Document.all(:limit => 20)
        render :xml => @documents
      end
    end
  end

  # GET /documents/1
  # GET /documents/1.xml
  def show
    @document = Document.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @document }
    end
  end

  def search
    @page = [params[:page].to_i, 1].max
    @per_page = (params[:per_page] || 20).to_i
    @per_page = 20 if @per_page < 0
    @per_page = [@per_page, 100].min
    before = Time.now
    words = params[:query].to_s.split
    if words.empty?
      @documents = []
    else
      options = {:limit => @per_page}
      @offset = (@page - 1) * @per_page
      options[:offset] = @offset if @offset > 0
      options[:expression] = Proc.new do |record|
        expression = nil
        words.each do |word|
          if expression.nil?
            expression = record.content =~ word
          else
            expression &= record.content =~ word
          end
        end
        expression
      end
      @total_entries = Document.count(options[:expression])
      @documents = Document.find(:all, options)
    end
    @elapsed = Time.now - before
  end
end
