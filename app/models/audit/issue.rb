class Audit::Issue < Audit::Base
  def self.write(card)
    super(card, after: snapshot(card))
  end

  def self.refuse(product_id:, reason:)
    AuditLog.record(
      action: "#{Card.model_name.singular}.#{name.demodulize.downcase}",
      outcome: :refused,
      metadata: { "product_id" => product_id, "reason" => reason }
    )
  end

  def self.snapshot(card)
    {
      "product_id" => card.product_id,
      "price_value" => card.price_value,
      "payout_rate" => card.payout_rate.to_s
    }
  end
  private_class_method :snapshot
end
