require 'version'
require 'openssl'
require 'rest-client'

class VsacUsersController < ApplicationController
  def create
    if user = VsacUser.authenticate(params[:user], params[:password])
      render(:file => File.join(Rails.root, 'public/404.html'), :status => 200, :layout => false)
    else
      render(:file => File.join(Rails.root, 'public/500.html'), :status => 401, :layout => false)
    end
  end

  def show
    httpAuth = request.headers['Authorization']
    if httpAuth
      userBinary = httpAuth.split(" ").last
      userStr = Base64.decode64(userBinary)
      userPass = userStr.split(":")
      userName = userPass.first
      password = userPass.last

      if user = VsacUser.authenticate(userName, password)
        render(:file => File.join(Rails.root, 'public/404.html'), :status => 200, :layout => false)
      else
        render(:file => File.join(Rails.root, 'public/500.html'), :status => 401, :layout => false)
      end
    else
      render(:file => File.join(Rails.root, 'public/404.html'), :status => 404, :layout => false)
    end
  end
end
