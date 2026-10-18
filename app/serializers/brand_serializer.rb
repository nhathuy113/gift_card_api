class BrandSerializer
  include Alba::Resource

  attributes :id, :name, :state, :custom_fields
end
