# frozen_string_literal: true

require 'test_helper'

class ClientTest < Minitest::Test
  context 'a Bitcoiner client' do
    setup do
      @bcd = Bitcoiner.new 'testuser', 'testpass'
    end

    should 'have a simple and useful inspect' do
      assert_equal '#<Bitcoiner::Client "http://testuser:testpass@127.0.0.1:8332" >', @bcd.inspect
    end

    context 'balance operation' do
      setup do
        response = Typhoeus::Response.new(code: 200, body: "{\"result\":12.34000000,\"error\":null,\"id\":\"jsonrpc\"}\n")
        Typhoeus.stub('http://testuser:testpass@127.0.0.1:8332').and_return(response)
      end

      teardown do
        Typhoeus::Expectation.clear
      end

      should 'get the balance' do
        @result = @bcd.balance
        assert_equal 12.34, @result
      end
    end

    context 'accounts operation' do
      setup do
        response = Typhoeus::Response.new(code: 200, body: "{\"result\":{\"\":0.0,\"Your Address\":0.0,\"pi\":3.14,\"ben\":100.00},\"error\":null,\"id\":\"jsonrpc\"}\n")
        Typhoeus.stub('http://testuser:testpass@127.0.0.1:8332').and_return(response)
      end

      teardown do
        Typhoeus::Expectation.clear
      end

      should 'return a hash of Account objects' do
        @result = @bcd.accounts
        assert_kind_of Hash, @result
        @result.each do |k, a|
          assert_kind_of Bitcoiner::Account, a
          assert_equal k, a.name
        end

        assert_equal 'pi', @result['pi'].name
      end
    end
  end
end
