require 'csv'

class City
  attr_reader :soundex, :metaphone, :real_name, :name, :simple_name, :idx, :label, :masked_zip, :zipcodes, :params

  def initialize(params)
    @name = params[:name]
    @simple_name = params[:simple_name]
    @real_name = params[:real_name]
    @soundex = Utils.soundex(@real_name)
    @metaphone = Utils.metaphone(@real_name)
    @zipcodes = params[:zipcode].split('-')
    @masked_zip = self.class.masked_zip(@zipcodes)
    @params = params
    @idx = params[:idx]
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

  def self.preload
    return if @cities.present?

    @metaphones = []
    @soundexes = []

    @cities = CSV.foreach(File.open(Rails.root.join('config', 'cities.csv'))).each_with_index.map do |row, i|
      c = City.new(
        idx: i,
        _id: row[0],
        department: row[1],
        slug: row[2],
        name: row[3],
        simple_name: row[4],
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

      @metaphones << [c.metaphone, i]
      @soundexes << [c.soundex, i]

      c
    end

    @metaphones.sort!
    @soundexes.sort!
  end

  def self.search(term)
    puts Utils.soundex(term)
    (by_soundex_prefix(Utils.soundex(term)) + by_metaphone_prefix(Utils.metaphone(term))).uniq
  end

  def self.by_soundex_prefix(soundex)
    by_prefix(soundex, @soundexes)
  end

  def self.by_metaphone_prefix(metaphone)
    return []
    by_prefix(metaphone, @metaphones)
  end

  def self.by_prefix(prefix, sorted_array)
    idx = sorted_array.bsearch_index { |el| el[0] >= prefix }
    return [] if idx.nil?

    results = []
    while idx < sorted_array.size && sorted_array[idx][0].start_with?(prefix)
      results << @cities[sorted_array[idx][1]]
      idx += 1
    end

    results
  end

  def self.[](i)
    @cities[i]
  end
end

City.preload
