module Reports
  class Base < ApplicationService
    def initialize(from: nil, to: nil)
      @from = parse_date(from)
      @to = parse_date(to)
      if @from.nil? && @to.nil?
        @from = @to = Date.current
      end
    end

    private

    def parse_date(value)
      return if value.blank?

      Date.parse(value.to_s)
    end

    def payout_sum
      table = Card.arel_table
      table[:price_value] * table[:payout_rate] / 100
    end

    def totals_for(cards)
      issued_cards = ranged_cards(cards, :issued_at)
      cancelled_cards = ranged_cards(cards.cancelled, :cancelled_at)
      {
        "issued_count" => issued_cards.count,
        "issued_total" => issued_cards.sum(:price_value),
        "payout_total" => issued_cards.sum(payout_sum).to_f,
        "cancelled_count" => cancelled_cards.count,
        "cancelled_total" => cancelled_cards.sum(:price_value)
      }
    end

    def metrics_for(totals, id)
      {
        "issued_count" => totals[:issued_counts][id] || 0,
        "issued_total" => totals[:issued_totals][id] || 0,
        "payout_total" => (totals[:issued_payouts][id] || 0).to_f,
        "cancelled_count" => totals[:cancelled_counts][id] || 0,
        "cancelled_total" => totals[:cancelled_totals][id] || 0
      }
    end

    def grouped_totals(cards, group_by)
      issued_cards = ranged_cards(cards, :issued_at)
      cancelled_cards = ranged_cards(cards.cancelled, :cancelled_at)
      {
        issued_counts: issued_cards.group(group_by).count,
        issued_totals: issued_cards.group(group_by).sum(:price_value),
        issued_payouts: issued_cards.group(group_by).sum(payout_sum),
        cancelled_counts: cancelled_cards.group(group_by).count,
        cancelled_totals: cancelled_cards.group(group_by).sum(:price_value)
      }
    end

    def ranged_cards(cards, column)
      return cards if no_dates?

      in_range(cards, column)
    end

    def cards_in_window(cards)
      return cards if no_dates?

      in_range(cards, :issued_at).or(in_range(cards.cancelled, :cancelled_at))
    end

    def report_ids(cards, group_by)
      cards_in_window(cards).distinct.pluck(group_by)
    end

    def no_dates?
      @from.nil? && @to.nil?
    end

    def in_range(scope, column)
      scope = scope.where(column => @from.beginning_of_day..) if @from
      scope = scope.where(column => ..@to.end_of_day) if @to
      scope
    end
  end
end
