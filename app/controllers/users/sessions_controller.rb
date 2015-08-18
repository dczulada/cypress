class Users::SessionsController < Devise::SessionsController

  def create
    if VsacUser.authenticate(params[:vsacuser], params[:vsacpassword])
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      throw(:warden)
    end
  end
end
