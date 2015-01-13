module ActivePermission
  #   class UserPermission < ActivePermission::Base
  #     def initialize(user)
  #       if user.admin?
  #         can 'manage/root', :index
  #       else
  #         can 'root', :all
  #       end
  #     end
  #   end
  class Base
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
    def can!(controllers, actions, *resource)
      if can?(controllers, actions, *resource)
        true
      else
        raise AccessDenied.new("Access denied by #{self.class.name} to #{resource.inspect}")
      end
    end
  end
end
