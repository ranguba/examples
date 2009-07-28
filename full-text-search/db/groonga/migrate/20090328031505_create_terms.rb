class CreateTerms < ActiveGroonga::Migration
  def self.up
    create_table :terms,
                 :type => :patricia_trie,
                 :key_type => "ShortText",
                 :default_tokenizer => "TokenBigram" do |t|
    end
  end

  def self.down
    drop_table :terms
  end
end
