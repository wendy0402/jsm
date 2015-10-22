class Jsm::Drawer::Graphviz
  API_URL = "https://chart.googleapis.com/chart"
  def self.generate_url(state_machine)
    new(state_machine).generate_url
  end

  def initialize(state_machine)
    @state_machine = state_machine
    @diagraph = Jsm::Drawer::Digraph.new(@state_machine)
  end

  def generate_url
    diagram = @diagraph
    "#{API_URL}?cht=gv&chl=digraph{#{diagram}}"
  end
end
