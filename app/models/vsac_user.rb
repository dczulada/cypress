class VsacUser

  def self.authenticate(username, password)
    RestClient.post 'https://vsac.nlm.nih.gov/vsac/ws/Ticket', {username: username, password: password}
    return true
    rescue Exception => e
      return false
  end
end