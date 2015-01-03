module ActivePermission
  module ControllerAdditions
    module ClassMethods
      # Sets up a before filter which loads the model resource into an instance variable by name.
      #
      #   class BooksController < ApplicationController
      #     resource :book
      #   end
      #
      #   class BooksController < ApplicationController
      #     authorize :book do
      #       Book.find(params[:id])
      #     end
      #   end
      #
      # Options:
      # [:+only+]
      #   Work as before filter parameter
      #
      # [:+except+]
      #   Work as before filter parameter
      #
      # [:+if+]
      #   Work as before filter parameter
      #
      # [:+unless+]
      #   Work as before filter parameter
      #
      # [:+object+]
      #   Object used to fetch record (string, symbol or class)
      #
      # [:+through+]
      #   Load this resource through another one.
      #
      # [:+association+]
      #   The name of the association to fetch the child records through the parent resource
      #
      # [:+key+]
      #   The name of parameters from params
      #
      # [:+parent+]
      #   Fetch first record from scope

      def resource(name, options = {}, &block)
        send(:before_action, options.slice(:only, :except, :if, :unless)) do |controller|
          if block_given?
            instance_variable_set "@#{name}", controller.instance_eval(&block)
          else
            if options[:through] and options[:association]
              object = instance_variable_get("@#{options[:through].to_s}")
              object = object.send(options[:association])
            elsif [Symbol, String].include? options[:object].class
              object = send(options[:object])
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

      def authorize(resources = nil, options = {}, &block)
        send(:before_action, options.slice(:only, :except, :if, :unless)) do |controller|
          if block_given?
            instance_variable_set "@#{name}", controller.instance_eval(&block)
          else
            objects = Array(resources).map {|resource| instance_variable_get("@#{resource.to_s}") }
            unless current_permission.can?(controller.params[:controller], controller.params[:action], *objects)
              if current_user.nil?
                raise AccessDeniedForAnonymous.new("Access denied by #{@current_permission.class.name} to anonymous in #{controller.params[:controller]}::#{controller.params[:action]}")
              else
                raise AccessDenied.new("Access denied by #{@current_permission.class.name} to #{objects.inspect} in #{controller.params[:controller]}::#{controller.params[:action]}")
              end
            end
          end
        end
      end
    end
    def self.included(base)
      base.extend ClassMethods
      base.delegate :can?, :can_any?, to: :current_permission
      base.helper_method :can?, :can_any?
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include ActivePermission::ControllerAdditions
  end
end
