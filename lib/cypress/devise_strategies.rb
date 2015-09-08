module Devise
  module Strategies
    class Vsac < Base
      def authenticate!
        proxy = ENV['http_proxy']
        nlm_license= APP_CONFIG["nlm"]["license_code"]
        if HealthDataStandards::Util::NLMHelper.validateNLMUser(proxy, nlm_license, params['vsacuser'], params['vsacpassword'])
          true
        else
          fail!("NLM Username and Password are not valid")
        end
      end
    end
  end
end