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
    @addresses = @context["addresses"]
    @names = @context["names"]
    @attachments = @context["attachments"]
  end

  def feed(path)
    data = File.read(path)
    mail = Mail.new(data)
    message = @messages.add
    message["subject"] = to_utf8(mail.subject.value)
    message["date"] = Time.parse(mail.date.value)

    register_address(message, "from", mail.from)
    register_addresses(message, "to", mail.to)

    if mail.multipart?
      mail.parts.each_with_index do |part, i|
        if i.zero?
          message["text"] = to_utf8(part.body.decoded)
          message["raw"] = part.body.decoded
        else
          attachment = @attachments.add
          attachment["filename"] = to_utf8(part.filename)
          attachment["content_type"] = part.content_type.value
          attachment["text"] = to_utf8(part.body.decoded)
          attachment["raw"] = part.body.decoded
          message.append("attachments", attachment)
        end
      end
    else
      message["text"] = to_utf8(mail.body.decoded)
      message["raw"] = mail.body.decoded
    end
  end

  private
  def to_utf8(string)
    return nil if string.nil?
    NKF.nkf("-w", string)
  end

  def register_address(message, key, address_list)
    register_addresses(message, key, address_list) do |person|
      message[key] = person
    end
  end

  def register_addresses(message, key, address_list, &block)
    address_list.send(:tree).addresses.each do |address|
      existing_addresses = @addresses.select do |record|
        record["value"] == address.address
      end

      if existing_addresses.size.zero?
        _address = @addresses.add(:value => address.address)
      else
        _address = existing_addresses.to_a[0].key
      end
      existing_people = @people.select do |record|
        record[".addresses.value"] == address.address
      end

      if existing_people.size.zero?
        person = @people.add
        person.append("addresses", _address)
      else
        person = existing_people.to_a[0].key
      end

      name = address.display_name
      if name
        name = to_utf8(name)
        name = @names.add(:value => name)
      end
      person.append("names", name) if name

      if block
        yield(person)
      else
        message.append(key, person)
      end
    end
  end
end

archiver = Archiver.new
ARGV.each do |file|
  archiver.feed(file)
end
