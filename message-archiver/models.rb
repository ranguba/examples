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
        schema.create_table("names") do |table|
          table.short_text("value")
        end

        schema.create_table("people",
                            :type => :hash,
                            :key_type => "ShortText") do |table|
          table.reference("names", "names", :type => :vector)
        end

        schema.create_table("attachments") do |table|
          table.short_text("name")
          table.short_text("content_type")
          table.text("text")
          table.unsigned_integer("size")
        end

        schema.create_table("headers",
                            :type => :patricia_trie,
                            :key_type => "ShortText") do |table|
          table.short_text("value")
        end

        schema.create_table("messages") do |table|
          table.short_text("subject")
          table.time("date")
          table.time("received_date")
          table.reference("from", "people")
          table.reference("to", "people", :type => :vector)
          table.reference("cc", "people", :type => :vector)
          table.reference("bcc", "people", :type => :vector)
          table.reference("reply_to", "people", :type => :vector)
          table.short_text("return_path", :type => :vector)
          table.short_text("message_id")
          table.short_text("in_reply_to")
          table.short_text("references", :type => :vector)
          table.reference("headers", "headers", :type => :vector)
          table.text("body")
          table.unsigned_integer("size")
        end

        schema.create_table("terms",
                            :key_type => "ShortText",
                            :type => :patricia_trie,
                            :key_normalize => true,
                            :sub_records => true,
                            :default_tokenizer => "TokenBigram") do |table|
          table.index("messages.subject")
          table.index("messages.body")
          table.index("headers.value")
          table.index("names.value")
          table.index("attachments.name")
          table.index("attachments.text")
        end
      end
    end
  end
end
