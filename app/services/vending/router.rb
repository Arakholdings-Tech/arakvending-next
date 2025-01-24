class Vending::Router
  class << self
    def draw(&)
      @routes ||= {}
      @namespace = 'default'
      @routes[@namespace] = {}
      instance_eval(&)
    end

    def namespace(namespace, &)
      @routes[namespace] = {} if @routes[namespace].nil?
      @namespace = namespace

      instance_eval(&)
    end

    def command(message_type, to:)
      controller, action = to.split('#')
      @routes[@namespace][message_type] = {
        controller: "#{controller.camelize}Controller".constantize,
        action: action.to_sym,
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
