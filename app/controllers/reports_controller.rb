# frozen_string_literal: true

class ReportsController < ApplicationController

  before_action :set_statement, only: [:create]

  def new
    Rails.logger.debug "\n-------- REPORT NEW --------"
  end

  def edit
    Rails.logger.debug "\n-------- REPORT EDIT --------"
  end

  def create
    Rails.logger.debug "\n-------- REPORT CREATE --------"

    respond_to do |format|
      format.html
      format.js
        # @report = Report.new(report_params[:report])
        kind = Report.kinds[params[:report][:kind]]

        @report = @statement.reports.build(report_params[:report])
        @report.kind = kind

        if current_user
          @report.voter = current_user
        else
          @report.voter = Voter.find(1)
        end

        Rails.logger.debug @report.inspect

        if @report.save!
          Rails.logger.debug "\n-------- REPORT CREATE saved! --------"
        else
          @report.errors.full_messages
        end
    end
  end

  def update
    Rails.logger.debug "\n-------- REPORT UPDATE --------"
  end

  def destroy
    Rails.logger.debug "\n-------- REPORT DESTROY --------"
  end
end

private

def set_statement
  Rails.logger.debug "\n\n-------- REPORT SET_STATEMENT start --------\n\n"
  @statement = Statement.find(report_params[:statement_id])
  Rails.logger.debug "\n\n-------- REPORT SET_STATEMENT end --------\n\n"
end

def report_params
  params.permit(:report, :kind, :statement_id)
end
