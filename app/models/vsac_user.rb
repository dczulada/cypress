class VsacUser

  def self.authenticate(username, password)
  	
    #RestClient.post 'https://vsac.nlm.nih.gov/vsac/ws/Ticket', {username: username, password: password}
    nlmResult = RestClient.post 'https://uts-ws.nlm.nih.gov/restful/isValidUMLSUser', {user: username, password: password, licenseCode: APP_CONFIG['nlm']['license_code']}
    doc = Nokogiri::XML(nlmResult)
    if doc.search('Result').text == 'true'
      return true
    else 
      return false
    end
    rescue Exception => e
      return false
  end
end
