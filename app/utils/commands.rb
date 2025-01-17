module Commands
  COMMANDS = {
    poll: 0x41,
    ack: 0x42,
    machine_status: 0x52,
    request_sync_info: 0x31,
    select_buy: 0x06,
    select_selection: 0x05,
    dispensing_status: 0x04,
    report_selection: 0x11,
    recieve_money: 0x27
  }.freeze

  COMMAND_MAP = {
    poll: 'POLL',
    ack: 'ACK',
    machine_status: 'MACHINE_STATUS',
    request_sync_info: 'REQUEST_SYNC_INFO',
    select_buy: 'REQUEST_BUY',
    dispensing_status: 'DISPENSING_STATUS',
    report_selection: 'REPORT_SELECTION',
    select_selection: 'SELECT_SELECTION',
    recieve_money: 'RECIEVE_MONEY'
  }.freeze

  def self.get_command(command)
    COMMAND_MAP[COMMANDS.key(command)]
  end
end
