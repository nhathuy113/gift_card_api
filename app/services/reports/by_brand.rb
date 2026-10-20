module Reports
  class ByBrand < Base
    GROUP_BY = { products: :brand_id }

    def call
      cards = Card.joins(product: :brand)
      totals = grouped_totals(cards, GROUP_BY)

      Brand.where(id: report_ids(cards, GROUP_BY)).order(:name).map do |brand|
        { "brand_id" => brand.id, "name" => brand.name, **metrics_for(totals, brand.id) }
      end
    end
  end
end
