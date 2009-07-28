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
    before = Time.now
    words = params[:query].to_s.split
    if words.empty?
      @documents = []
    else
      @documents = Document.find(:all, :limit => 20) do |record|
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
    end
    @elapsed = Time.now - before
  end
end
