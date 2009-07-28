class CreateUsers < ActiveGroonga::Migration
  def self.up
    create_table :users do |t|
      t.string :original_id
      t.string :name

      t.timestamps
    end

    add_index_column :terms, :users, :original_id
    add_index_column :terms, :users, :name
  end

  def self.down
    drop_table :users
  end
end
