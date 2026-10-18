class ClientSerializer
  include Alba::Resource

  attributes :id, :email, :role, :state

  attribute :payout_rate do |client|
    client.payout_rate.to_f
  end
end
