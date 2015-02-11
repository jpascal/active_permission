require 'active_permission/version'
require 'active_permission/controller_additions'
require 'active_permission/base'

module ActivePermission
  class AccessDenied < RuntimeError
    attr_reader :controller, :action, :resources
    def initialize(controller = nil , action = nil , resources = nil)
      @controller = controller
      @action = action
      @resources = resources
      message = "Access denied in #{@controller}::#{@action}"
      if resources
        message += ' on resources ' + resources.collect{|resource| resource.respond_to?(:id) ? "#{resource.class}(#{resource.id})}" : resource}.to_s
      end
      super(message)
    end
  end
end
