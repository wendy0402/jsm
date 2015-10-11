class Jsm::Machines
  @@machines = {}
  def self.add_machines(klass, state_machine)
    @@machines[klass.to_s] = state_machine
  end

  def self.machines(klass)
    @@machines[klass.to_s]
  end
end
