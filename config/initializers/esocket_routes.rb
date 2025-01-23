Rails.application.config.to_prepare do
  Esocket::Transport.routes.draw do
    namespace 'Admin' do
      action 'INIT', to: 'admin#init'
      action 'CLOSE', to: 'admin#close'
    end

    namespace 'Transaction' do
      action 'PURCHASE', to: 'purchase#process'
    end
  end
end
