class DocumentsController < ApplicationController
  # GET /documents
  # GET /documents.xml
  def index
    @documents = Document.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @documents }
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
