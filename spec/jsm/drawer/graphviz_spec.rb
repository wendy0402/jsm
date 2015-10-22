describe Jsm::Drawer::Graphviz do
  class GraphvizStateMachine < Jsm::Base
    attribute_name :test
    state :draft
    state :confirmed
    state :cancelled
    state :accepted

    event :confirm do
      transition from: :draft, to: :confirmed
    end

    event :accept do
      transition from: :confirmed, to: :accepted
    end
  end

  let(:graphviz) { Jsm::Drawer::Graphviz.new(GraphvizStateMachine) }

  it 'translate into right url' do
    url = "https://chart.googleapis.com/chart?cht=gv&chl=digraph{draft->confirmed[label=confirm];confirmed->accepted[label=accept]}"
    expect(graphviz.generate_url).to eq(url)
  end
end
