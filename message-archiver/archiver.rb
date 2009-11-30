#!/usr/bin/env ruby

require 'models'

require 'rubygems'
require 'mail'

require 'time'

Models.setup

class Archiver
  def initialize
    @context = Groonga::Context.default
    @messages = @context["messages"]
    @people = @context["people"]
    @names = @context["names"]
  end

  def feed(path)
    data = File.read(path)
    mail = Mail.new(data)
    message = @messages.add
    message["subject"] = to_utf8(mail.subject.value)
    message["date"] = Time.parse(mail.date.value)
    from = mail.from.send(:tree).addresses[0]
    from_person = @people[from.address] || @people.add(from.address)
    from_name = from.display_name
    if from_name
      from_name = to_utf8(from_name)
      from_name = @names.add(:value => from_name)
    end
    from_person.append("names", from_name) if from_name
    message["from"] = from_person
    message["body"] = to_utf8(mail.body.raw_source)
  end

  private
  def to_utf8(string)
    NKF.nkf("-w", string)
  end
end

archiver = Archiver.new
ARGV.each do |file|
  archiver.feed(file)
end
