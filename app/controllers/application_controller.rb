class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Deviseのログイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  # Deviseのサインアップ後のリダイレクト先を設定
  def after_sign_up_path_for(resource)
    dashboard_path
  end
end
