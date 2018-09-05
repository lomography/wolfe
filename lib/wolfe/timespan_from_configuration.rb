module Wolfe
  class TimespanFromConfiguration
    SUPPORTED_TIME_UNITS = %w(hours days months years).freeze

    def initialize(config)
      config = split_duration_and_unit(config)

      @duration = Integer(config['duration'])
      @unit = config['unit']
      @unit = (@unit.to_s << 's').to_sym unless @unit.to_s.end_with? 's'

      raise ArgumentError.new("Invalid time unit #{config['unit'].inspect}, expected one of #{SUPPORTED_TIME_UNITS.join(', ')}") unless supported_time_unit?
    end

    def timespan
      @duration.send(@unit)
    end

    def keep_one_backup?
      @duration.to_i != 0
    end

    private

      def supported_time_unit?
        SUPPORTED_TIME_UNITS.include?(@unit.to_s)
      end

      def split_duration_and_unit(config)
        { 'duration' => config.split('.')[0].to_i, 'unit' => config.split('.')[1].to_sym }
      end
  end
end
