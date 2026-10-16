module Cards
  class Issue < ApplicationService
    class Ineligible < StandardError; end
    class KeyReused < StandardError; end

    Result = Struct.new(:card, :created, keyword_init: true) do
      def created? = created
    end

    def initialize(client:, product_id:, idempotency_key:)
      @client = client
      @product_id = product_id.to_i
      @key = idempotency_key
    end

    def call
      if (card = @client.cards.find_by(idempotency_key: @key))
        raise KeyReused, "Idempotency key was used for a different product" if card.product_id != @product_id

        return Result.new(card: card, created: false)
      end

      raise Ineligible, "Client is inactive" unless @client.active?

      product = @client.accessible_products.issuable.find_by(id: @product_id)
      raise Ineligible, "Product is not available" unless product

      card = @client.cards.create!(
        product: product,
        activation_number: SecureRandom.alphanumeric(16).upcase,
        pin: format("%06d", SecureRandom.random_number(1_000_000)),
        price_value: product.price_value,
        payout_rate: @client.payout_rate,
        idempotency_key: @key,
        issued_at: Time.current
      )

      Result.new(card: card, created: true)
    rescue ActiveRecord::RecordNotUnique
      card = @client.cards.find_by!(idempotency_key: @key)
      Result.new(card: card, created: false)
    end
  end
end
