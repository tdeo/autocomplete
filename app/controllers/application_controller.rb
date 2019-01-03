class ApplicationController < ActionController::Base
  def search
    results = City.search(params[:term])

    results.sort_by! { |r| Utils.levenshtein(params[:term], r.real_name) }

    render json: results.first(15).map { |r| r.as_json.merge(label: "#{r.real_name} (#{r.masked_zip})" ) }
  end

  def city
    @city = City[params[:id].to_i]
    return render :head if @city.nil?

    render layout: false
  end
end
