module Api
  module V1
    module Client
      class CardsController < BaseController
        def index
          render json: CardSerializer.wrap(current_client.cards.order(issued_at: :desc))
        end

        def show
          render json: CardSerializer.new(current_client.cards.find(params[:id]))
        end

        def create
          key = card_params[:idempotency_key]
          if key.blank?
            return render json: { error: "idempotency_key is required" }, status: :bad_request
          end

          result = Cards::Issue.call(
            client: current_client,
            product_id: card_params[:product_id],
            idempotency_key: key
          )

          render json: CardSerializer.new(result.card), status: result.created? ? :created : :ok
        rescue Cards::Issue::Ineligible => e
          render json: { error: e.message }, status: :unprocessable_content
        rescue Cards::Issue::KeyReused => e
          render json: { error: e.message }, status: :conflict
        end

        def cancel
          card = current_client.cards.find(params[:id])
          if card.cancel
            render json: CardSerializer.new(card)
          else
            render json: { error: "Card already cancelled" }, status: :unprocessable_content
          end
        end

        private

        def card_params
          params.permit(:product_id, :idempotency_key)
        end
      end
    end
  end
end
