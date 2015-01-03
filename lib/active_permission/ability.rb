module ActivePermission
  #   class UserPermission < ActivePermission::Ability
  #     def initialize(user)
  #       if user.admin?
  #         can 'manage/root', :index
  #       else
  #         can 'root', :all
  #       end
  #     end
  #   end
  class Ability
    def can(controllers, actions, &block)
      @allowed_actions ||= {}
      Array(controllers).each do |controller|
        Array(actions).each do |action|
          @allowed_actions[[controller.to_s, action.to_s]] = block || true
        end
      end
    end
    def can?(controllers, actions, *resource)
      @allowed_actions ||= {}
      Array(controllers).each do |controller|
        Array(actions).each do |action|
          allowed = @allowed_actions[[controller.to_s, action.to_s]]
          result = allowed && (allowed == true || resource && allowed.call(*resource))
          return result if result == true
        end
      end
      false
    end
  end
end
