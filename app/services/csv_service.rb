# frozen_string_literal: true

# Flattens Works for serialization as CSV
class CsvService
  def self.call(...)
    new(...).call
  end

  def initialize(works:)
    @works = works
  end

  # @return [Array<String>] CSV rows
  def call
    [header] + work_forms.map { |work_form| row_for(work_form) }
  end

  private

  attr_reader :works

  def header
    WorkForm.new.serializable_hash(except: %i[keywords authors]).keys.tap do |headers|
      authors_count.times do |author_index|
        concat_for_author_header(headers:, author_index:)
      end
      keywords_count.times do |keyword_index|
        headers.concat(KeywordForm.new.serializable_hash.keys.map { |key| "keyword#{keyword_index + 1}_#{key}" })
      end
    end
  end

  def authors_count
    nested_count[:authors]
  end

  def keywords_count
    nested_count[:keywords]
  end

  def affiliations_count
    nested_count[:affiliations]
  end

  # rubocop:disable Metrics/AbcSize
  def nested_count
    @nested_count ||= { authors: 0, keywords: 0, affiliations: 0 }.tap do |counts|
      work_forms.each do |work_form|
        counts[:authors] = [work_form.authors.size, counts[:authors]].max
        counts[:keywords] = [work_form.keywords.size, counts[:keywords]].max
        work_form.authors.each do |author|
          counts[:affiliations] = [author.affiliations.size, counts[:affiliations]].max
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def work_forms
    @work_forms ||= works.map { |work| work_form_for(work) }
  end

  def work_form_for(work)
    cocina_object = Sdr::Repository.find(druid: work.druid)
    WorkCocinaMapperService.to_work(cocina_object:)
  end

  # rubocop:disable Metrics/AbcSize
  def row_for(work_form)
    work_form.serializable_hash(except: %i[keywords authors]).values.tap do |row|
      authors_count.times do |author_index|
        author_form = work_form.authors[author_index] || AuthorForm.new
        concat_for_author_form(author_form:, row:)
      end
      keywords_count.times do |keyword_index|
        keyword_form = work_form.keywords[keyword_index] || KeywordForm.new
        row.concat(keyword_form.serializable_hash.values)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def concat_for_author_form(author_form:, row:)
    row.concat(author_form.serializable_hash(except: %i[affiliations]).values)
    affiliations_count.times do |affiliation_index|
      affiliation_form = author_form.affiliations[affiliation_index] || AffiliationForm.new
      row.concat(affiliation_form.serializable_hash.values)
    end
  end

  def concat_for_author_header(headers:, author_index:)
    headers.concat(AuthorForm.new.serializable_hash(except: %i[affiliations]).keys.map do |key|
      "author#{author_index + 1}_#{key}"
    end)
    affiliations_count.times do |affiliation_index|
      headers.concat(AffiliationForm.new.serializable_hash.keys.map do |key|
        "author#{author_index + 1}_affiliation#{affiliation_index + 1}_#{key}"
      end)
    end
  end
end
