class ClientSerializer
  include Alba::Resource

  attributes :id, :email, :role, :state, :payout_rate
end
