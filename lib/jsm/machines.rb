class Jsm::Machines
  cattr_reader :machines
  @@machines = {}
  def self.add_machines(klass, state_machine)
    @@machines[klass.to_s] = state_machine
  end
end
