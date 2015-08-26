require 'version'
require 'openssl'
require 'rest-client'
require 'pry'

class VsacUsersController < ErrorsController

  def show
    httpAuth = request.headers['Authorization']
    if httpAuth
      userBinary = httpAuth.split(" ").last
      userStr = Base64.decode64(userBinary)
      userPass = userStr.split(":")
      userName = userPass.first
      password = userPass.last
      if user = VsacUser.authenticate(userName, password)
        respond_to do |format|
          format.all { render nothing: true, status: 200 }
        end
      else
        error_401
      end
    else
      error_401
    end
  end
end
