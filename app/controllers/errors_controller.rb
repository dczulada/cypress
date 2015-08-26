class ErrorsController < ApplicationController
  def error_404
    respond_to do |format|
      format.html { render template: 'errors/error_404', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def error_401
    respond_to do |format|
      format.html { render template: 'errors/error_401', layout: 'layouts/application', status: 401 }
      format.all { render nothing: true, status: 401 }
    end
  end

  def error_500
  end
end