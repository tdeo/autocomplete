require 'rubygems/text'

class Utils
  def self.ascii(str)
    str = str.downcase.tr('éèêêëàäâîïôöûüÿç', 'eeeeeaaaiioouuyc').encode('ASCII', replace: '', invalid: :replace, undef: :replace)
    str = str.gsub(/[^a-z]/, '').upcase
  end

  def self.levenshtein(a, b)
    @c ||= Class.new.extend(Gem::Text)
    @c.levenshtein_distance(a, b)
  end

  def self.soundex(string)
    string = ascii(string)
    first_char = string[0]

    %w(BFPV CGJKQSXZ DT L MN R).each do |g|
      string.gsub!(/([#{g}])([hw]?[#{g}])+/, '\1')
    end

    string = string[1..-1]
    string.gsub!(/[AEIOUYHW]/, '')

    %w(BFPV CGJKQSXZ DT L MN R).each_with_index do |g, i|
      string.tr!(g, "#{i + 1}")
    end

    first_char + string.ljust(2, '1')
  end

  def self.mysql_soundex(string)
    string = ascii(string)
    first_char = string[0]
    first_char_code = first_char.dup

    string = string.tr!('AEIOUYHW', '')

    %w(BFPV CGJKQSXZ DT L MN R).each_with_index do |g, i|
      string.tr!(g, "#{i + 1}")
      first_char_code.tr!(g, "#{i + 1}")
    end

    string.gsub!(/(.)\1+/, '\1')

    string = string[1..-1] if first_char_code[0] == string[0]

    first_char + string
  end

  def self.metaphone(string)
    'zde'
  end
end
