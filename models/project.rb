
# frozen_string_literal: true

require 'json'
require 'sequel'

module Dada
  # Models a project
  class Project < Sequel::Model
    one_to_many :requests
    plugin :association_dependencies, requests: :destroy

    plugin :timestamps

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'project',
            attributes: {
              id: id,
              title: title,
              descriptions: descriptions,
              user_id: user_id,
              secret_token_secure: secret_token_secure,
              public_url_secure: public_url_secure
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
