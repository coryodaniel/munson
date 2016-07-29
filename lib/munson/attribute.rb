module Munson
  class Attribute
    attr_reader :name
    attr_reader :cast_type
    attr_reader :options

    def initialize(name, cast_type, options={})
      options[:default] ||= nil
      options[:array]   ||= false
      @name      = name
      @cast_type = cast_type
      @options   = options
    end

    # Process a raw JSON value
    def process(value)
      value.nil? ? default_value : cast(value)
    end

    # Super naive casting!
    def cast(value)
      return (@options[:array] ? [] : nil) if value.nil?
      value.is_a?(Array) ?
        value.map { |v| cast_value(v) } :
        cast_value(value)
    end

    def cast_value(value)
      return nil if value.nil?

      case cast_type
      when Proc
        cast_type.call(value)
      when :string, :to_s, String
        value.to_s
      when :integer, :to_i, Fixnum
        value.to_i
      when :bigdecimal
        BigDecimal.new(value.to_s)
      when :float, :to_f, Float
        value.to_f
      when :date, Date
        Date.parse(value) rescue nil
      when :time, Time
        Time.parse(value) rescue nil
      else
        value
      end
    end


    # Serializes the value back to JSON datatype
    #
    def serialize(value)
      case options[:serialize]
      when Proc
        options[:serialize].call(value)
      when Symbol
        value.send(options[:serialize])
      else
        value
      end
    end

    def default_value
      case @options[:default]
      when Proc
        @options[:default].call
      when nil
        @options[:array] ? [] : nil
      else
        @options[:default].clone
      end
    end
  end
end
