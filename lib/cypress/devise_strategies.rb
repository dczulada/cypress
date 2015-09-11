module Devise
  module Strategies
    class Vsac < Base
      def valid?
        APP_CONFIG["nlm"]["enabled"] == true
      end
      def authenticate!
        proxy = ENV['http_proxy']
        nlm_license= APP_CONFIG["nlm"]["license_code"]
        nlm_url = APP_CONFIG["nlm"]["nlm_url"]
        if HealthDataStandards::Util::NLMHelper.validateNLMUser(nlm_url, proxy, nlm_license, params['vsacuser'], params['vsacpassword'])
          true
        else
          fail!("NLM Username and Password are not valid")
        end
      end
    end
  end
end