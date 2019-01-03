require 'rubygems/text'

class Utils
  SEPARATORS = ' \'()-'

  REPLACE = {
    "\u008C" => '',
    "\u009C" => '',
    "à" => 'a',
    "â" => 'a',
    "ç" => 'c',
    "è" => 'e',
    "é" => 'e',
    "ê" => 'e',
    "ë" => 'e',
    "î" => 'i',
    "ï" => 'i',
    "ô" => 'o',
    "û" => 'u',
    "ü" => 'u',
    "ÿ" => 'y',
    "œ" => 'oe',
  }

  TR = ['', '']
  REPLACE.each do |k, v|
    TR[0] << k.upcase
    TR[1] << v.upcase
  end

  def self.chars_freq
    freq = Hash.new { |h, k| h[k] = 0 }
    City.all.each { |city| city.real_name.each_char { |c| freq[c] += 1 } }
    pp freq.sort
    nil
  end

  def self.tokens(str)
    str = str.upcase.tr(*TR)
    str.split(/[^A-Z]+/)
  end

  def self.tokens_freq
    freq = Hash.new { |h, k| h[k] = 0 }
    City.all.each { |city| tokens(city.real_name).each { |word| freq[word] += 1 } }
    pp freq.sort_by(&:last).last(50)
    nil
  end

  def self.ascii(str)
    str = str.upcase.tr(*TR).encode('ASCII', replace: '', invalid: :replace, undef: :replace)
    str = str.gsub(/[^A-Z]/, '')
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

    string = string[1..-1] || ''
    string.gsub!(/[AEIOUYHW]/, '')

    %w(BFPV CGJKQSXZ DT L MN R).each_with_index do |g, i|
      string.tr!(g, "#{i + 1}")
    end

    first_char + string.ljust(2, '1')
  end

  def self.metaphone(string)
    string = ascii(string)
    string.gsub!(/([^C])\1+/, '\1')
    string = string[1..-1] if %w(KN GN PN AE WR).include?(string[0..1])
    string = string[0...-1] if string.end_with?('MB')

    string.gsub!(/SCH/, 'SKH')
    string.gsub!(/C(IA|H)/, 'X\1')
    string.gsub!(/C([IEY])/, 'S\1')
    string.tr!('C', 'K')

    string.gsub!(/D(GE|GY|GI)/, 'J\1')
    string.tr!('D', 'T')

    string.gsub!(/G(H[^AEIOUY$])/, '\1')
    string.gsub!(/G(N(ED)?)$/, '\1')

    string.gsub!(/(^|[^G])G([IEY])/, '\1J\2')
    string.tr!('G', 'K')

    string.gsub!(/([AEIOUY])H([^AEIOUY]|$)/, '\1\2')
    string.gsub!(/CK/, 'K')
    string.gsub!(/PH/, 'F')
    string.tr!('Q', 'K')
    string.gsub!(/S(H|IO|IA)/, 'X\1')

    string.gsub!(/T(IO|IA)/, 'X\1')
    string.gsub!(/TH/,'0')
    string.gsub!(/TCH/, 'CH')

    string.tr!('V', 'F')

    string.gsub!(/^WH/, 'W')
    string.gsub!(/W($|[^AEIOUY])/, '\1')

    string.gsub!(/^X/, 'S')
    string.gsub!(/X/, 'KS')

    string.gsub!(/Y($|[^AEIOUY])/, '\1')

    string.tr!('Z', 'S')

    (string[0] || '') + (string[1..-1] || '').tr('AEIOU', '')
  end
end
