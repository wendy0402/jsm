#list of all nodes
class Jsm::Drawer::Digraph
  attr_reader :state_machine
  def initialize(state_machine)
    @state_machine = state_machine
  end

  #list of all nodes
  # TODO: move it to different class(?)
  def nodes
    unless @nodes
      events = state_machine.events.values
      @nodes = events.map{ |event| to_nodes(event) }.flatten
    end
    @nodes
  end

  # convert it to string that is compatible with api Graphviz
  def to_s
    nodes.map(&:to_s).join(';')
  end

  private

  # convert transitions of event into nodes object
  # return value is array
  # e.g: [Jsm::Drawer::Node.new(:confirmed, :completed, :complete)]
  def to_nodes(event)
    nodes = []
    event.transitions.each do |transition|
      if transition.multiple_from?
        temp_nodes = transition.from.map{ |from| Jsm::Drawer::Node.new(from: from, to: transition.to, label: event.name) }
      else
        from = transition.from[0] # even only one it is still in array e.g: [:confirmed]
        temp_nodes = [Jsm::Drawer::Node.new(from: from, to: transition.to, label: event.name)]
      end
      nodes += temp_nodes
    end
    nodes
  end
end
