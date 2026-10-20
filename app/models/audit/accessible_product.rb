class Audit::AccessibleProduct
  def self.write(client, before_ids, after_ids)
    return if before_ids == after_ids

    AuditLog.record(
      action: "client_accessible_product.update",
      record: client,
      before: { "product_ids" => before_ids },
      after: { "product_ids" => after_ids }
    )
  end
end
