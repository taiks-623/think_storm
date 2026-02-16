require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2
      option :name, "line"

      option :client_options, {
        site: "https://access.line.me",
        authorize_url: "/oauth2/v2.1/authorize",
        token_url: "https://api.line.me/oauth2/v2.1/token"
      }

      option :scope, "profile openid email"

      uid { raw_info["sub"] }

      info do
        {
          name: raw_info["name"],
          email: raw_info["email"],
          image: raw_info["picture"]
        }
      end

      def raw_info
        @raw_info ||= begin
          decoded = JWT.decode(
            access_token.params["id_token"],
            nil,
            false
          ).first
          decoded
        rescue StandardError
          {}
        end
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
