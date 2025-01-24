Rails.application.config.to_prepare do
  Vending::Transport.routes.draw do
    command 'POLL', to: 'vending/ack#handle'
    command 'SELECT_SELECTION', to: 'vending/selection#selected'
    command 'SET_SELECTION_INVENTORY', to: 'vending/selection#inventory'
  end
end
