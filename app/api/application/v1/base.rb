# frozen_string_literal: true

require 'grape-swagger'

module Application
  module V1
    # Base API
    class Base < Grape::API
      mount V1::Sessions
      mount V1::Users
      mount V1::Forums
      mount V1::Topics
      mount V1::Posts

      add_swagger_documentation(
        api_version: 'v1',
        hide_documentation_path: true,
        mount_path: '/api/v1/docs',
        hide_format: true,
        info: {
          title: 'Forum API',
          description: 'A description of the API.'
        }
      )
    end
  end
end
