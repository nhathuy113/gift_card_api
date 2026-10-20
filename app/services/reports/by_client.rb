module Reports
  class ByClient < Base
    GROUP_BY = :client_id

    def call
      cards = Card.joins(:client)
      totals = grouped_totals(cards, GROUP_BY)

      Client.where(id: report_ids(cards, GROUP_BY)).order(:email).map do |client|
        { "client_id" => client.id, "email" => client.email, **metrics_for(totals, client.id) }
      end
    end
  end
end
