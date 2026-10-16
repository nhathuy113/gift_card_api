class ClientAccessibleProduct < ApplicationRecord
  belongs_to :client
  belongs_to :product

  validates :product_id, uniqueness: { scope: :client_id }
end
