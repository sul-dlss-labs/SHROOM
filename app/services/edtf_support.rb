# frozen_string_literal: true

# Helpers for working with Extended Date/Time Format (EDTF)
class EdtfSupport
  def self.to_edtf(year:, month: nil, day: nil)
    return if year.nil?

    date_parts = [year, month, day].compact
    date = Date.new(*date_parts)
    case date_parts.length
    when 1
      date.year_precision!
    when 2
      date.month_precision!
    end
    date.edtf
  end

  # @param [String] date
  # @return [Date, nil]
  def self.parse_with_precision(date:)
    return if date.nil?

    edtf = Date.edtf(date)
    case date.count('-')
    when 0
      edtf.year_precision!
    when 1
      edtf.month_precision!
    end
    edtf
  end

  # @param [Edtf] edtf
  # @return [Integer, nil] the month, or nil if the EDTF is not month-precision
  def self.month_for(edtf:)
    return if edtf.nil?

    # .month will return 1 when year-precision
    edtf.values[1]
  end

  # @param [Edtf] edtf
  # @return [Integer, nil] the day, or nil if the EDTF is not day-precision
  def self.day_for(edtf:)
    return if edtf.nil?

    # .day will return 1 when year- or month-precision
    edtf.values[2]
  end
end
