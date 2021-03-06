class ApplicationController < ActionController::Base
  def search
    query = Utils.ascii(params[:term])
    soundex = Utils.soundex(query)

    results = City.by_soundex(query).sort_by! { |r| r.score(query) }

    idx = results.bsearch_index { |r| r.score(query) >= 1000 }

    prefixes = []
    contains = []
    sounds = []
    others = []

    results[idx.nil? ? 0..-1 : 0...idx].each do |r|
      ascii_name = Utils.ascii(r.real_name)

      if ascii_name.start_with?(query)
        prefixes << r
      elsif ascii_name.include?(query)
        contains << r
      elsif Utils.soundex(ascii_name).start_with?(soundex)
        sounds << r
      else
        others << r
      end
    end

    to_display = prefixes.first(3) + contains.first(3)

    to_display += sounds.first(to_display.size < 3 ? 3 : 2)
    to_display += others.first(1)

    if (to_display & City.big_cities).empty?
      to_display.unshift(City.big_cities.min_by { |r| r.score(query) })
    end

    render json: to_display.first(10).map { |r| { label: "#{r.real_name} (#{r.masked_zip})", id: r.id } }
  end

  def city
    @city = City[params[:id].to_i]
    return render :head if @city.nil?

    render layout: false
  end
end
