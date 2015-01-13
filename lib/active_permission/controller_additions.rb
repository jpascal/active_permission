module ActivePermission
  module ControllerAdditions
    module ClassMethods
      # Sets up a before filter which loads the model resource into an instance variable by name.
      #
      #   class BooksController < ApplicationController
      #     resource :book, object: 'Book'
      #   end
      #
      #   class BooksController < ApplicationController
      #     resource :book do
      #       Book.find(params[:id])
      #     end
      #   end
      #
      # Options:
      # [:+only+]
      #   Work as before filter parameter.
      #
      # [:+except+]
      #   Work as before filter parameter.
      #
      # [:+if+]
      #   Work as before filter parameter.
      #
      # [:+unless+]
      #   Work as before filter parameter.
      #
      # [:+object+]
      #   Object used to fetch record (string, symbol or class).
      #
      # [:+through+]
      #   Load this resource through another one.
      #
      # [:+association+]
      #   The name of the association to fetch the child records through the parent resource.
      #
      # [:+key+]
      #   The name of parameters from params.
      #
      # [:+parent+]
      #   Fetch first record from scope.

      def resource(name, options = {}, &block)
        send(:before_action, options.slice(:only, :except, :if, :unless)) do |controller|
          if block_given?
            instance_variable_set "@#{name}", controller.instance_eval(&block)
          else
            if options[:through] and options[:association]
              object = instance_variable_get("@#{options[:through]}").send(options[:association])
            elsif options[:object].nil?
              raise AccessDenied.new("Access denied in #{controller.params[:controller]}::#{controller.params[:action]}. Required set a option :object.")
            elsif options[:object].kind_of? Symbol
              object = send(options[:object])
            elsif options[:object].kind_of? String
              object = options[:object].camelize.constantize
            else
              object = options[:object]
            end

            if options[:parent]
              object = object.where(id: controller.params[(options[:key] || :id).to_sym]).first!
            else
              if controller.params[:action].to_sym == :new
                object = object.new
              elsif not [:create, :index].include?(controller.params[:action].to_sym)
                object = object.where(id: controller.params[(options[:key] || :id).to_sym]).first!
              end
            end
            instance_variable_set "@#{name}", object
          end
        end
      end

      def authorize(resources = nil, options = {})
        send(:before_action, options.slice(:only, :except, :if, :unless)) do |controller|
          objects = Array(resources).map {|resource| instance_variable_get("@#{resource.to_s}") }
          current_permissions.can!(controller.params[:controller], controller.params[:action], *objects)
        end
      end
      def current_permissions
        @ability ||= ActivePermission::Ability.new
      end
    end

    module  InstanceMethods
      def authorize!(resource, options = {})
        options = params.merge(options)
        current_permissions.can!(options[:controller], options[:action], resource)
      end

      def authorize?(resource, options = {})
        options = params.merge(options)
        current_permissions.can?(options[:controller], options[:action], resource)
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
      base.delegate :can?, :can!, to: :current_permissions
      base.helper_method :can?, :can!
    end

  end
end

