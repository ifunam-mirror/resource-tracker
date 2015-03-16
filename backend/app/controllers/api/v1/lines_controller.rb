class Api::V1::LinesController < Api::V1::BaseController
  before_filter :determine_scope

  def index
    @lines = @scope.all
    render json: @lines
  end

  private

  def determine_scope
    @project = Project.find params[:project_slug]
    @scope = @project.lines
  end
end
