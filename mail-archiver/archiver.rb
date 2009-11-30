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
  end

  def feed(data)
    mail = Mail.read(data)
    _mail = @mails.add
    _mail["subject"] = NKF.nkf("-w", mail.subject.value)
    _mail["date"] = Time.parse(mail.date.value)
    _mail["body"] = NKF.nkf("-w", mail.body.raw_source)
  end
end

archiver = Archiver.new
ARGV.each do |file|
  archiver.feed(file)
end
