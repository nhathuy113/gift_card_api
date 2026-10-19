class CardSerializer
  def initialize(card)
    @card = card
  end

  def as_json(*)
    @card.as_json(except: %i[pin])
  end
end
