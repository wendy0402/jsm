class Jsm::Callbacks::ChainCollection
  def initialize(klass)
    @klass = klass
    @chains = {}
  end

  def add_chain(context,chain)
    @chains[context] = chain
  end

  def [](context)
    @chains[context] ||= Jsm::Callbacks::Chain.new(context)
  end
end
