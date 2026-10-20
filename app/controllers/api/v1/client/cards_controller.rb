module Api
  module V1
    module Client
      class CardsController < BaseController
        def create
          number = card_params[:activation_number].to_s
          unless number.match?(Card::ACTIVATION_NUMBER_FORMAT)
            return render json: { error: I18n.t("activerecord.errors.models.card.attributes.activation_number.invalid") }, status: :bad_request
          end

          result = Cards::Issue.call(
            client: current_client,
            product_id: card_params[:product_id],
            activation_number: number
          )

          render json: CardSerializer.new(result.card), status: result.created? ? :created : :ok
        rescue Cards::Issue::Ineligible => e
          render json: { error: e.message }, status: :unprocessable_content
        rescue Cards::Issue::KeyReused => e
          render json: { error: e.message }, status: :conflict
        end

        def cancel
          card = current_client.cards.find_by!(activation_number: params[:activation_number])
          card.cancel!
          render json: CardSerializer.new(card)
        rescue ActiveRecord::RecordInvalid
          render json: { error: I18n.t("cards.cancel.already_cancelled") }, status: :unprocessable_content
        end

        private

        def card_params
          params.permit(:product_id, :activation_number)
        end
      end
    end
  end
end
