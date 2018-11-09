require "spec_helper"

RSpec.describe SpotifyTokenSwapService, "::ConfigHelper" do
  context "singleton" do
    include SpotifyTokenSwapService::ConfigHelper

    it "uses only one instance of SpotifyTokenSwapService::Config" do
      all_environment_variables do
        a = config.object_id
        b = config.object_id
        expect(a).to eq b
      end
    end
  end
end

RSpec.describe SpotifyTokenSwapService, "::Config" do
  context "bad environment" do
    it "should raise an error if no env variables" do
      environment_variables([]) do
        expect {
          config = SpotifyTokenSwapService::Config.clone.instance
        }.to raise_error SpotifyTokenSwapService::ConfigError
      end
    end

    it "should raise an error if only ENCRYPTION_SECRET env" do
      environment_variables(["ENCRYPTION_SECRET"]) do
        expect {
          config = SpotifyTokenSwapService::Config.clone.instance
        }.to raise_error SpotifyTokenSwapService::ConfigError
      end
    end
  end

  context "good environment" do
    it "should be ok if all env variables" do
      all_environment_variables do
        config = SpotifyTokenSwapService::Config.clone

        expect { config = config.instance }.not_to raise_error
        expect(config.has_client_credentials?).to be true
        expect(config.has_encryption_secret?).to be true
      end
    end

    it "should be ok if all client env variables" do
      environment_variables(%w(
        SPOTIFY_CLIENT_ID
        SPOTIFY_CLIENT_SECRET
        SPOTIFY_CLIENT_CALLBACK_URL
      )) do
        config = SpotifyTokenSwapService::Config.clone

        expect { config = config.instance }.not_to raise_error
        expect(config.has_client_credentials?).to be true
        expect(config.has_encryption_secret?).to be false
      end
    end

    it "should have valid property-assignment" do
      all_environment_variables do
        config = SpotifyTokenSwapService::Config.clone.instance

        expect(config.client_id).to eq "sample-client-id"
        expect(config.client_secret).to eq "sample-client-secret"
        expect(config.client_callback_url).to eq "sample-client-callback-url://"
        expect(config.encryption_secret).to eq "|NwDQ-R1J,:1ct^@m+[s&C(k}2g]g+T|AuPXz07AT7jB oFjk|tCY+|/|Y:u[Er8"
      end
    end
  end
end
