class Jsm::Drawer::Node
  attr_reader :from, :to, :label
  def initialize(params = {})
    @from = params[:from]
    @to = params[:to]
    @label = params[:label]
  end

  def to_s
    "#{from.to_s}->#{to.to_s}[label=#{label.to_s}]"
  end
end
