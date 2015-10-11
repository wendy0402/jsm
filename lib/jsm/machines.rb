class Jsm::Machines
  def self.add_machines(klass, state_machine)
    @@machines ||= {}
    @@machines[klass.to_s] = state_machine
  end

  def self.machines
    @@machines ||= {}
  end
end
