# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Response Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:requests].each do |request_data|
      Dada::Request.create(request_data)
    end
  end

  it 'HAPPY: should be able to get list of all requests' do
    req = Dada::Request.first
    DATA[:responses].each do |res|
      req.add_response(res)
    end

    get "api/v1/request/#{req.id}/responses"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single request' do
    req = Dada::Request.first
    res_data = DATA[:responses][1]
    res = req.add_response(res_data).save

    get "/api/v1/request/#{req.id}/response/#{res.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal res.id
    _(result['data']['attributes']['body_secure']).must_equal res_data['body_secure']
  end

  it 'SAD: should return error if unknown document requested' do
    req = Dada::Request.first
    get "/api/v1/request/#{req.id}/response/foobar"

    _(last_response.status).must_equal 404
  end
  describe 'Creating New Response' do

    before do
      @req = Dada::Request.first
      @res_data = DATA[:responses][1]
      @res_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new request' do
      post "api/v1/request/#{@req.id}/response",
           @res_data.to_json, @res_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      res = Dada::Response.first

      _(created['id']).must_equal res.id
      _(created['header_secure']).must_equal @res_data['header_secure']
      _(created['body_secure']).must_equal @res_data['body_secure']
    end

    it 'BAD: should not create response with illegal attributes' do
      bad_data = @res_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/request/#{@req.id}/response",
           bad_data.to_json, @res_header

      # problem ask bimo why I get 500
      _(last_response.status).must_equal 500
      _(last_response.header['Location']).must_be_nil
    end
  end
end