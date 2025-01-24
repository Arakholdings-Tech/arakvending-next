class IoMessage < ApplicationRecord
  enum :status, { pending: 'pending', processing: 'processing', completed: 'completed' }

  scope :pending_for, ->(queue) { where(status: 'pending', queue: queue).order(created_at: :asc) }

  def self.next_for(queue)
    transaction do
      command = pending_for(queue).first
      command.update!(status: 'processing') if command.present?
      command
    end
  end
end
