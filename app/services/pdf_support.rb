# frozen_string_literal: true

# Methods for working with PDFs.
class PdfSupport
  def self.first_pages(path:, count: 3)
    doc = HexaPDF::Document.open(path)
    (count..(doc.pages.count - 1)).to_a.reverse_each do |index|
      doc.pages.delete_at(index)
    end
    io = StringIO.new
    doc.write(io)
    io.string
  end
end
