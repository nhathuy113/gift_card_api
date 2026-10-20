module AccessibleProductIds
  def accessible_product_ids=(ids)
    self.class.transaction do
      before_ids = accessible_product_ids.sort
      super
      Audit::AccessibleProduct.write(self, before_ids, accessible_product_ids.sort)
    end
  end
end
