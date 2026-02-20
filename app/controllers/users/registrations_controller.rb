class Users::RegistrationsController < Devise::RegistrationsController
  private

  def update_resource(resource, params)
    # OmniAuthユーザーはパスワードなしで更新可能
    if resource.provider.present?
      resource.update_without_password(params)
    else
      super
    end
  end

  def after_update_path_for(resource)
    profile_path
  end
end
