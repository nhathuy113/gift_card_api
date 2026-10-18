class ProductSerializer
  include Alba::Resource

  attributes :id, :brand_id, :name, :price_value, :state, :custom_fields
end
