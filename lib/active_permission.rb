require 'active_permission/version'
require 'active_permission/controller_additions'
require 'active_permission/base'

module ActivePermission
  class AccessDenied < RuntimeError
    attr_reader :controller, :action, :object
    def initialize(controller = nil , action = nil , object = nil)
      @controller = controller
      @action = action
      @object = object
      super("Access denied in #{@controller}::#{@action} - #{object.inspect}")
    end
  end
end
