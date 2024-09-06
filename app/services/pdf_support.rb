# frozen_string_literal: true

# Methods for working with PDFs.
class PdfSupport
  def self.subset_pages(path:, first_pages: 3, last_pages: 2)
    doc = HexaPDF::Document.open(path)
    page_indexes = (0..(doc.pages.count - 1)).to_a
    page_indexes.shift(first_pages)
    page_indexes.pop(last_pages)
    page_indexes.reverse_each do |index|
      doc.pages.delete_at(index)
    end
    io = StringIO.new
    doc.write(io)
    io.string
  end
end
