# frozen_string_literal: true

# Controller for Works
class WorksController < ApplicationController
  def index
    @works = Work.order(id: :desc).page(params[:page])
  end

  def new
    @work_form = build_new_work_form
    Rails.logger.info("Work: #{@work_form.to_json}")
  end

  def create
    @work_form = WorkForm.new(work_params)
    return render :new, status: :unprocessable_entity unless @work_form.valid?

    Rails.logger.info("Work: #{@work_form.to_json}")
    @cocina_object = WorkCocinaMapperService.to_cocina(work: @work_form)
    @work = Work.create!(title: @work_form.title)
    work_file.update!(work: @work)

    job_ib = Sdr::DepositService.call(work: @work, cocina_object: @cocina_object)
    Rails.logger.info("Deposit job: #{job_ib}")

    # This is just for demo purposes.
    # Don't forget to remove create.html.erb and remove data-turbo=false from new.html.erb.
    render :create
  end

  private

  def build_new_work_form
    return WorkForm.new unless params.key?(:work_file)

    GrobidService.call(path: work_file.path)
  end

  def work_params
    # Perhaps these can be introspected from the model?
    params.require(:work).permit(
      :title, :abstract, :publisher,
      :published_year, :published_month, :published_day,
      authors_attributes: [
        :first_name, :last_name, { affiliations_attributes: %i[organization department] }
      ],
      keywords_attributes: %i[value]
    )
  end

  def work_file
    @work_file ||= WorkFile.find(work_file_param)
  end

  def work_file_param
    @work_file_param ||= params[:work_file] || params[:work][:work_file]
  end
end
