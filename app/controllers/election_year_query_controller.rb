class ElectionYearQueryController < ApplicationController
  def results
  	@year = params[:year]
  end
end
