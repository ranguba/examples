#!/usr/bin/env ruby

require 'models'

require 'rubygems'
require 'mail'

require 'time'

Models.setup

class Archiver
  def initialize
    @context = Groonga::Context.default
    @mails = @context["mails"]
    @people = @context["people"]
    @names = @context["names"]
  end

  def feed(data)
    mail = Mail.read(data)
    _mail = @mails.add
    _mail["subject"] = NKF.nkf("-w", mail.subject.value)
    _mail["date"] = Time.parse(mail.date.value)
    from = mail.from.send(:tree).addresses[0]
    from_person = @people[from.address] || @people.add(from.address)
    from_name = from.display_name
    if from_name
      from_name = NKF.nkf("-w", from_name)
      from_name = @names.add(:value => from_name)
    end
    from_person.append("names", from_name) if from_name
    _mail["from"] = from_person
    _mail["body"] = NKF.nkf("-w", mail.body.raw_source)
  end
end

archiver = Archiver.new
ARGV.each do |file|
  archiver.feed(file)
end
