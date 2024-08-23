# frozen_string_literal: true

# Lays out a form in 2 columns, with form in 1st column and PDF display in 2nd column.
class FormLayoutComponent < ViewComponent::Base
  renders_one :form

  def initialize(work_file:)
    @work_file = work_file
    super()
  end

  attr_reader :work_file
end
