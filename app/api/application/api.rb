# frozen_string_literal: true

module Application
  # Main Application Api Class
  class Api < Grape::API
    mount Application::V1::Base
  end
end
