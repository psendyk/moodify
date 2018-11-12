require File.dirname(File.realpath(__FILE__)) + "/../spotify_token_swap_service.rb"
require "climate_control"

module RSpec
  module Helpers
    module EnvironmentVariables
      def all_environment_variables(&block)
        environment_variables(%w(
          SPOTIFY_CLIENT_ID
          SPOTIFY_CLIENT_SECRET
          SPOTIFY_CLIENT_CALLBACK_URL
          ENCRYPTION_SECRET
        ), &block)
      end

      def environment_variables(variables, &block)
        variables.map!(&:to_sym)

        service_env = {
          "SPOTIFY_CLIENT_ID": "sample-client-id",
          "SPOTIFY_CLIENT_SECRET": "sample-client-secret",
          "SPOTIFY_CLIENT_CALLBACK_URL": "sample-client-callback-url://",
          "ENCRYPTION_SECRET": "|NwDQ-R1J,:1ct^@m+[s&C(k}2g]g+T|AuPXz07AT7jB oFjk|tCY+|/|Y:u[Er8"
        }.map { |key, value| { key => variables.include?(key) ? value : nil } }

        ClimateControl.modify(service_env.reduce(:merge), &block)
      end
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.include RSpec::Helpers::EnvironmentVariables
end
