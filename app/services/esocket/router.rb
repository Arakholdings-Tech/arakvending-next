class Esocket::Router
  class << self
    def draw(&block)
      @routes ||= {}
      @namespace = 'default'
      @routes[@namespace] = {}
      instance_eval(&block)
    end

    def namespace(namespace, &block)
      @routes[namespace] = {} if @routes[namespace].nil?
      @namespace = namespace

      instance_eval(&block)
    end

    def action(message_type, to:)
      controller, action = to.split('#')
      @routes[@namespace][message_type] = {
        controller: "#{controller.camelize}Controller".constantize,
        action: action.to_sym
      }
    end

    def dispatch(transport, message_type, message, namespace = 'default')
      if @routes[namespace].present? && route = @routes[namespace][message_type]
        controller = route[:controller].new
        controller.dispatch(route[:action], transport, message_type, message)
      else
        Rails.logger.warn "No route found for message type: #{message_type}"
      end
    end
  end
end
