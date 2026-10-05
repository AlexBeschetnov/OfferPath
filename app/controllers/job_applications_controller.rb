class JobApplicationsController < ApplicationController
  before_action :set_job_application, only: %i[show edit update destroy move]

  def index
    @job_applications = applications.search(params[:q]).recent
    @job_applications = @job_applications.where(status: params[:status]) if JobApplication::STATUSES.include?(params[:status])

    respond_to do |format|
      format.html
      format.csv do
        send_data "﻿" + JobApplication.to_csv(@job_applications), # BOM so Excel detects UTF-8
                  filename: "job-applications-#{Date.current}.csv",
                  type: "text/csv; charset=utf-8"
      end
    end
  end

  def board
    @columns = applications.recent.group_by(&:status)
  end

  def show
    @status_changes = @job_application.status_changes.order(:created_at, :id)
  end

  def new
    @job_application = applications.new
    @job_application.status = params[:status] if JobApplication::STATUSES.include?(params[:status])
  end

  def create
    @job_application = applications.new(job_application_params)

    if @job_application.save
      redirect_to @job_application, notice: "Application added"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @job_application.update(job_application_params)
      redirect_to @job_application, notice: "Changes saved"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @job_application.destroy!
    redirect_to job_applications_path, notice: "Application deleted", status: :see_other
  end

  def move
    if @job_application.update(status: params[:status])
      redirect_back_or_to board_job_applications_path, status: :see_other,
        notice: "#{@job_application.company} moved to #{JobApplication.human_status(@job_application.status)}"
    else
      redirect_back_or_to board_job_applications_path, status: :see_other, alert: "Unknown status"
    end
  end

  private

  # Every query goes through the current user, so nobody can reach someone else's data by id.
  def applications
    Current.user.job_applications
  end

  def set_job_application
    @job_application = applications.find(params[:id])
  end

  def job_application_params
    params.expect(job_application: %i[company position posting_url salary_from salary_to status
                                      applied_on next_step next_step_on notes])
  end
end
