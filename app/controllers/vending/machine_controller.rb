class Vending::MachineController < MessageController
  def status(transport, command, data)
    machine_id = data[15..24].pack('C*')
    if Machine.any?
      Machine.first.update(machine_id: machine_id)
    else
      Machine.create(machine_id: machine_id)
    end
  end
end
