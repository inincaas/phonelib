module Phonelib
  # class for parsed phone number, includes validation and formatting methods
  class Phone
    # defining reader methods for class variables
    attr_reader :original, # original phone number passed for parsing
                :sanitized # sanitized phone number representation

    # including module that has all phone analyze logic
    include Phonelib::PhoneAnalyzer

    # class initialization method
    #
    # ==== Attributes
    #
    # * +phone+ - Phone number for parsing
    # * +country_data+ - Hash of data for parsing
    #
    def initialize(phone, country_data)
      puts phone
      @original = phone
      @sanitized = sanitize_phone(@original)
      if @sanitized.empty?
        @analyzed_data = {}
      else
        @national_number, @analyzed_data = analyze(@sanitized, country_data)
      end
    end

    # Returns all phone types that matched valid patterns
    def types
      @analyzed_data.flat_map { |iso2, data| data[:valid] }.uniq
    end

    # Returns first phone type that matched
    def type
      types.first
    end

    # Returns human representation of all matched phone types
    def human_types
      types.map { |type| Core::TYPES_DESC[type] }
    end

    # Return human representation of phone type
    def human_type
      Core::TYPES_DESC[type]
    end

    # Returns all countries that matched valid patterns
    def countries
      @analyzed_data.map { |iso2, data| iso2 }
    end

    # Return countries with valid patterns
    def valid_countries
      @valid_countries ||= countries.select do |iso2|
        @analyzed_data[iso2][:valid].any?
      end
    end

    # Returns first country that matched valid patterns
    def country
      @country ||= begin
        valid_countries.find do |iso2|
          @analyzed_data[iso2][Core::MAIN_COUNTRY_FOR_CODE] == 'true'
        end || valid_countries.first
      end
    end

    # Returns whether a current parsed phone number is valid
    def valid?
      @analyzed_data.select { |iso2, data| data[:valid].any? }.any?
    end

    # Returns whether a current parsed phone number is invalid
    def invalid?
      !valid?
    end

    # Returns whether a current parsed phone number is possible
    def possible?
      @analyzed_data.select { |iso2, data| data[:possible].any? }.any?
    end

    # Returns whether a current parsed phone number is impossible
    def impossible?
      !possible?
    end

    # Returns formatted national number
    def national
      return @national_number unless valid?
      format, prefix, rule = get_formatting_data

      # add space to format groups, change first group to rule,
      # change rule's constants to values
      format_string = format[:format].gsub(/(\d)\$/, '\\1 $').gsub('$1', rule)
          .gsub(/(\$NP|\$FG)/, '$NP' => prefix, '$FG' => '$1')

      if matches = @national_number.match(/#{format[Core::PATTERN]}/)
        format_string.gsub(/\$\d/) { |el| matches[el[1].to_i] }
      else
        @national_number
      end
    end

    # Returns e164 formatted phone number
    def international
      return "+#{@sanitized}" unless valid?

      format = @analyzed_data[country][:format]
      if matches = @national_number.match(/#{format[Core::PATTERN]}/)
        national = format[:format].gsub(/\$\d/) { |el| matches[el[1].to_i] }
      else
        national = @national_number
      end

      "+#{@analyzed_data[country][Core::COUNTRY_CODE]} #{national}"
    end

    # Returns whether a current parsed phone number is valid for specified
    # country
    #
    # ==== Attributes
    #
    # * +country+ - ISO code of country (2 letters) like 'US', 'us' or :us
    #               for United States
    #
    def valid_for_country?(country)
      country = country.to_s.upcase
      @analyzed_data.select do |iso2, data|
        country == iso2 && data[:valid].any?
      end.any?
    end

    # Returns whether a current parsed phone number is invalid for specified
    # country
    #
    # ==== Attributes
    #
    # * +country+ - ISO code of country (2 letters) like 'US', 'us' or :us
    #               for United States
    #
    def invalid_for_country?(country)
      !valid_for_country?(country)
    end

    private

    # Sanitizes passed phone number. Returns only digits from passed string.
    def sanitize_phone(phone)
      phone && phone.gsub(/[^0-9]+/, '') || ''
    end
  end
end
