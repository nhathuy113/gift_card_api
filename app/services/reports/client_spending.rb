module Reports
  class ClientSpending < Base
    def initialize(client_id:, from: nil, to: nil)
      super(from: from, to: to)
      @client = ::Client.find(client_id)
    end

    def call
      totals_for(@client.cards)
    end
  end
end
