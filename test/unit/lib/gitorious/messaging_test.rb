# encoding: utf-8
#--
#   Copyright (C) 2011 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require File.dirname(__FILE__) + '/../../../test_helper'
require "gitorious/messaging"

class DummyPublisher
  include Gitorious::Messaging::Publisher

  class Queue
    attr_reader :messages, :name
    def initialize(name); @name = name; end
    def publish(payload); (@messages ||= []) << JSON.parse(payload); end
    def to_s; name; end
  end

  def inject(queue)
    @counter ||= 1
    res = Queue.new("injected: #{queue} ##{@counter}")
    @counter += 1
    res
  end
end

class GitoriousMessagingTest < ActiveSupport::TestCase
  context "publisher" do
    context "queue" do
      should "locate queue from inject" do
        publisher = DummyPublisher.new

        assert_equal "injected: my_queue #1", publisher.queue("my_queue").to_s
      end

      should "reuse previously injected queue" do
        publisher = DummyPublisher.new
        queue = publisher.queue("my_queue")

        assert_equal "injected: my_queue #1", publisher.queue("my_queue").to_s
      end
    end

    context "publish" do
      should "call publish on queue" do
        publisher = DummyPublisher.new

        publisher.publish("queue_name", :id => 42, :action => "do_it")

        assert_equal([{ "id" => 42,
                        "action" => "do_it" }],
                     publisher.queue("queue_name").messages)
      end
    end
  end
end
