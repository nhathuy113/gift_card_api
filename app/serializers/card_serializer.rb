class CardSerializer
  def self.wrap(cards)
    cards.map { |card| new(card) }
  end

  def initialize(card)
    @card = card
  end

  def as_json(*)
    @card.as_json(except: %i[pin idempotency_key])
  end
end
