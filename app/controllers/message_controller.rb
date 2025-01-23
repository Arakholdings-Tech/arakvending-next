class MessageController
  def dispatch(action, *args)
    public_send(action.to_sym, *args)
  end
end
