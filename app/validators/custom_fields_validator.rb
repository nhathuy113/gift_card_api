class CustomFieldsValidator < ActiveModel::EachValidator
  MAXIMUM = 5

  def validate_each(record, attribute, value)
    unless value.is_a?(Array) && value.all? { |f| valid_item?(f) }
      record.errors.add(attribute, "must be an array of {name, value}")
      return
    end

    record.errors.add(attribute, "maximum is #{MAXIMUM}") if value.size > MAXIMUM
  end

  private

  def valid_item?(item)
    item.is_a?(Hash) && (item["name"] || item[:name]).present?
  end
end
