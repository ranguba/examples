module DocumentsHelper
  def snippet(query)
    open_tag = "<span class=\"keyword\">"
    close_tag = "</span>"
    _snippet = Groonga::Snippet.new(:width => 100,
                                    :default_open_tag => open_tag,
                                    :default_close_tag => close_tag,
                                    :html_escape => true)
    query.split(/\s+/).each do |word|
      _snippet.add_keyword(word)
    end
    _snippet
  end
end
