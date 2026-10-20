module AccessibleProductIds
  def accessible_product_ids=(ids)
    before_ids = accessible_product_ids.sort
    super
    Audit::AccessibleProduct.write(self, before_ids, accessible_product_ids.sort)
  end
end
