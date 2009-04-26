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
    @n_documents = Document.count do |query|
      query.content.include(params[:query])
    end
    before = Time.now
    @documents = Document.find_all_by_content(params[:query], :limit => 20)
    @elapsed = Time.now - before
  end
end
