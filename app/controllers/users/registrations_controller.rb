class Users::RegistrationsController < Devise::RegistrationsController
  private

  def update_resource(resource, params)
    if resource.provider.present?
      resource.update_without_password(params)
    else
      super
    end
  end

  def after_update_path_for(resource)
    edit_users_profile_path
  end
end
