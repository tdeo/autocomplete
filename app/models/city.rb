require 'csv'

class City
  attr_reader :real_name, :id, :masked_zip, :zipcodes, :params

  def initialize(params)
    @real_name = params[:real_name]
    @zipcodes = params[:zipcode].split('-')
    @masked_zip = self.class.masked_zip(@zipcodes)
    @params = params
    @id = params[:idx]
  end

  def self.masked_zip(zipcodes)
    mask = ''

    (0...5).each do |i|
      if zipcodes.all? { |z| z[i] == zipcodes[0][i] }
        mask << zipcodes[0][i]
      else
        mask << 'x'
      end
    end

    mask
  end

  def self.all
    @cities
  end

  def self.big_cities
    @big_cities ||= @cities.sort_by { |c| -c.params[:pop_2010] }.first(50)
  end


  def self.preload
    return if @cities.is_a?(Array) && @cities.size > 30_000
    puts 'Preloading'

    @soundexes = []

    @cities = CSV.foreach(File.open(Rails.root.join('config', 'cities.csv'))).each_with_index.map do |row, i|
      c = City.new(
        idx: i,
        _id: row[0],
        department: row[1],
        # slug: row[2],
        # name: row[3],
        # simple_name: row[4],
        real_name: row[5],
        # soundex: row[6] || '',
        # metaphone: row[7] || '',
        zipcode: row[8],
        # commune_number: row[9],
        # insee_id: row[10],
        # arrondissement: row[11],
        # canton: row[12],
        pop_2010: row[14].to_i,
        pop_1999: row[15].to_i,
        pop_2012: row[16].to_i,
        density_2010: row[17].to_f,
        area: row[18].to_f,
        long_deg: row[19].to_f,
        lat_deg: row[20].to_f,
        # long_grd: row[21].to_f,
        # lat_grd: row[22].to_f,
        # long_dms: row[23].to_f,
        # lat_dms: row[24].to_f,
        min_alt: row[25].to_f,
        max_alt: row[26].to_f,
      )

      Utils.tokens(c.real_name).each do |token|
        @soundexes << [Utils.soundex(token), c.id]
      end

      c
    end

    @soundexes.sort!
    puts 'Finish preloading'
  end

  def score(query)
    ascii_name = Utils.ascii(real_name)
    return 1000 if Utils.levenshtein(query, ascii_name) >= (ascii_name.size + query.size) / 2
    return 1000 if Utils.levenshtein(query, ascii_name) - (ascii_name.size - query.size).abs >= [ascii_name.size, query.size].min / 2

    name_tokens = Utils.tokens(real_name)

    s = Utils.tokens(query).map do |token|
      name_tokens.map { |name_token| Utils.levenshtein(token, name_token) }.min
    end.sum

    s -= Math.log10(params[:pop_2010])
  end

  def self.search(query)
    (big_cities + by_soundex(query)).uniq
  end

  def self.by_soundex(query)
    matches = Hash.new { |h, k| h[k] = 0 }

    Utils.tokens(query).each do |token|
      having_soundex_prefix(Utils.soundex(token)) do |idx|
        matches[idx] += 1
      end
    end

    matches.each_key.map { |k| self[k] }
  end

  def self.having_soundex_prefix(prefix)
    idx = @soundexes.bsearch_index { |el| el[0] >= prefix }
    return [] if idx.nil?

    while idx < @soundexes.size
      if @soundexes[idx][0].start_with?(prefix)
        yield @soundexes[idx][1]
        idx += 1
      else
        break
      end
    end
  end

  def self.[](i)
    @cities[i]
  end
end

City.preload
