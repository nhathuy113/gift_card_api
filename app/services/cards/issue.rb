module Cards
  class Issue < ApplicationService
    class Ineligible < StandardError; end
    class KeyReused < StandardError; end

    Result = Struct.new(:card, :created, keyword_init: true) do
      def created? = created
    end

    def initialize(client:, product_id:, activation_number:)
      @client = client
      @product_id = product_id.to_i
      @activation_number = activation_number
    end

    def call
      card = find_card
      return reused_card(card) if card

      refuse!("cards.issue.client_inactive") unless @client.active?

      Result.new(card: create_card(product_for_issue), created: true)
    rescue ActiveRecord::RecordNotUnique
      reused_card(Card.find_by!(activation_number: @activation_number))
    end

    private

    def find_card
      Card.find_by(activation_number: @activation_number)
    end

    def reused_card(card)
      return Result.new(card: card, created: false) if card.client_id == @client.id && card.product_id == @product_id

      refuse!("cards.issue.activation_number_used", KeyReused)
    end

    def product_for_issue
      product = @client.accessible_products.find_by(id: @product_id)
      refuse!("cards.issue.product_not_accessible") unless product

      issuable = @client.accessible_products.issuable.find_by(id: @product_id)
      refuse!("cards.issue.product_unavailable") unless issuable

      issuable
    end

    def refuse!(key, error = Ineligible)
      message = I18n.t(key)
      Audit::Issue.refuse(product_id: @product_id, reason: message)
      raise error, message
    end

    def create_card(product)
      @client.cards.create!(
        product: product,
        activation_number: @activation_number,
        pin: format("%06d", SecureRandom.random_number(1_000_000)),
        price_value: product.price_value,
        payout_rate: @client.payout_rate,
        issued_at: Time.current
      )
    end
  end
end
