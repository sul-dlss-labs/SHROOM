class EdtfSupport
  def self.to_edtf(year:, month: nil, day: nil)
    return if year.nil?

    date_parts = [ year, month, day ].compact
    date = Date.new(*date_parts)
    case date_parts.length
    when 1
      date.year_precision!
    when 2
      date.month_precision!
    end
    date.edtf
  end
end
