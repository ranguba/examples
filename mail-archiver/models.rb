base_dir = File.dirname(__FILE__)
ruby_groonga_base_dir = File.join(base_dir, "..", "..", "groonga")
ruby_groonga_base_dir = File.expand_path(ruby_groonga_base_dir)
$LOAD_PATH.unshift(File.join(ruby_groonga_base_dir, "ext"))
$LOAD_PATH.unshift(File.join(ruby_groonga_base_dir, "lib"))

require 'groonga'
require 'fileutils'

module Models
  class << self
    def setup(db_dir=nil)
      environment = ENV["RACK_ENV"] || "development"
      base_dir = File.dirname(__FILE__)
      db_dir ||= File.join(base_dir, "db", environment)
      FileUtils.mkdir_p(db_dir)
      db_path = File.join(db_dir, "db.groonga")
      if File.exist?(db_path)
        Groonga::Database.open(db_path)
      else
        Groonga::Database.create(:path => db_path)
      end
      ensure_schema
    end

    def ensure_schema
      context = Groonga::Context.default
      Groonga::Schema.define do |schema|
        schema.create_table("people",
                            :type => :hash,
                            :key_type => "ShortText") do |table|
          table.short_text("names", :type => :vector)
        end

        schema.create_table("mails",
                            :type => :hash,
                            :key_type => "ShortText") do |table|
          table.short_text("subject")
          table.text("content")
          table.reference("sender", "people")
          table.reference("recipients", "people", :type => :vector)
        end

        schema.create_table("terms",
                            :key_type => "ShortText",
                            :type => :patricia_trie,
                            :key_normalize => true,
                            :sub_records => true,
                            :default_tokenizer => "TokenBigram") do |table|
          table.index("mails.subject")
          table.index("mails.content")
          table.index("people.names")
        end
      end
    end
  end
end
