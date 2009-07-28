class CreateDocuments < ActiveGroonga::Migration
  def self.up
    create_table :documents do |t|
      t.string :title
      t.text :content
      t.string :version
      t.string :url
      t.references :user
      t.references :source

      t.timestamps
    end

    add_index_column :terms, :documents, :title
    add_index_column :terms, :documents, :content
  end

  def self.down
    drop_table :documents
  end
end
