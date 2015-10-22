describe Jsm::Drawer::Digraph do
  class JsmDrawerStateMachine < Jsm::Base
    attribute_name :test
    state :draft
    state :confirmed
    state :delayed
    state :cancelled
    state :accepted
    state :removed

    event :confirm do
      transition from: :draft, to: :confirmed
    end

    event :delay do
      transition from: :confirmed, to: :delayed
    end

    event :cancel do
      transition from: :confirmed, to: :cancelled
    end

    event :accept do
      transition from: :confirmed, to: :accepted
      transition from: :delayed, to: :accepted
    end

    event :remove do
      transition from: [:draft, :confirmed, :cancelled], to: :removed
    end
  end

  let(:diagram) { Jsm::Drawer::Digraph.new(JsmDrawerStateMachine) }
  let(:diagraph) { diagram.nodes }

  describe '.nodes' do
    let(:expected_result) { [] }
    let(:graphs) { diagraph.map { |graph| [graph.from, graph.to, graph.label] }}
    it 'return list of all nodes' do
      expected_nodes = []
      expected_nodes.push Jsm::Drawer::Node.new(from: :draft, to: :confirmed, label: :confirm)
      expected_nodes.push Jsm::Drawer::Node.new(from: :confirmed, to: :delayed, label: :delay)
      expected_nodes.push Jsm::Drawer::Node.new(from: :confirmed, to: :cancelled, label: :cancel)

      expected_nodes = expected_nodes.map { |node| [node.from, node.to, node.label] }
      expect(graphs).to include(*expected_nodes)
    end

    it 'for event with multiple transition create several nodes with same label' do
      expected_nodes = []
      expected_nodes.push Jsm::Drawer::Node.new(from: :confirmed, to: :accepted, label: :accept)
      expected_nodes.push Jsm::Drawer::Node.new(from: :delayed, to: :accepted, label: :accept)

      expected_nodes = expected_nodes.map { |node| [node.from, node.to, node.label] }
      expect(graphs).to include(*expected_nodes)
    end

    it 'for transition with multiple from, it create several nodes with same to and label' do
      expected_nodes = []
      expected_nodes.push Jsm::Drawer::Node.new(from: :draft, to: :removed, label: :remove)
      expected_nodes.push Jsm::Drawer::Node.new(from: :confirmed, to: :removed, label: :remove)
      expected_nodes.push Jsm::Drawer::Node.new(from: :cancelled, to: :removed, label: :remove)

      expected_nodes = expected_nodes.map { |node| [node.from, node.to, node.label] }
      expect(graphs).to include(*expected_nodes)
    end
  end

  describe 'to_s' do
    it 'return the diagram in string version' do
      result = [
        'draft->confirmed[label=confirm]',
        'confirmed->delayed[label=delay]',
        'confirmed->cancelled[label=cancel]',
        'confirmed->accepted[label=accept]',
        'delayed->accepted[label=accept]',
        'draft->removed[label=remove]',
        'confirmed->removed[label=remove]',
        'cancelled->removed[label=remove]'
      ]

      connection_list = diagram.to_s.split(';')
      expect(connection_list).to match_array(result)
    end
  end
end
