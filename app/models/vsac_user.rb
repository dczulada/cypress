class VsacUser

  def self.authenticate(username, password)
    RestClient.proxy = "http://gatekeeper.mitre.org:80/"
    RestClient.post 'https://vsac.nlm.nih.gov/vsac/ws/Ticket', {username: username, password: password}
    return true
    rescue Exception => e
      return false
  end
end
