require 'active_permission/version'
require 'active_permission/controller_additions'
require 'active_permission/base'

module ActivePermission
  class AccessDenied < RuntimeError
    attr_reader :secure
    def initialize(message, secure = true)
      super(message)
      @secure = secure
    end
  end
end
