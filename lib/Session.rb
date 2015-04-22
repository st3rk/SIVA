class Session
	def initialize(record)
		@timestamp = record[:raw_timestamp]
		@start_time = record[:raw_start_time]
		@start_lat = record[:raw_start_position_lat]
		@start_long = record[:raw_start_position_long]
		@total_elapsed_time = record[:raw_total_elapsed_time]
		@total_timer_time = record[:raw_total_timer_time]
		@total_calories = record[:raw_total_calories]
		@avg_speed = record[:raw_avg_speed]
		@total_ascent = record[:raw_total_ascent]
		@total_descent = record[:raw_total_descent]
	end
	def utc_time
		# convert fit timestamp it to Posix timestamp
		# fit format : seconds since UTC 00:00 Dec 31 1989
		# Posix format : seconds since UTC 00:00 Jan 01 1970
		return (DateTime.strptime(@timestamp.to_s, '%s')  >> 12 * 20) - 1
	end
	def time
		# convert fit timestamp it to Posix timestamp
		# fit format : seconds since UTC 00:00 Dec 31 1989
		# Posix format : seconds since UTC 00:00 Jan 01 1970
		return self.utc_time.new_offset(DateTime.now.offset)
	end
	def geojson_timestamp
		# convert time to geojson timestamp (milliseconds since the epoch)
		return self.time.to_time.to_i * 1000
	end
	def utc_start_time
		# convert fit timestamp it to Posix timestamp
		# fit format : seconds since UTC 00:00 Dec 31 1989
		# Posix format : seconds since UTC 00:00 Jan 01 1970
		return (DateTime.strptime(@start_time.to_s, '%s')  >> 12 * 20) - 1
	end
	def start_time
		# convert fit timestamp it to Posix timestamp
		# fit format : seconds since UTC 00:00 Dec 31 1989
		# Posix format : seconds since UTC 00:00 Jan 01 1970
		return self.utc_start_time.new_offset(DateTime.now.offset)
	end
	def geojson_start_time
		# convert time to geojson timestamp (milliseconds since the epoch)
		return self.start_time.to_time.to_i * 1000
	end
	def start_lat
		# convert semicircles to degres
		# formula : deg = semicircles * 180 / 2^31
				return @start_lat.to_f * 180.to_f / 2147483648.to_f
	end
	def start_lng
		# convert semicircles to degres
		# formula : deg = semicircles * 180 / 2^31
				return @start_long.to_f * 180.to_f / 2147483648.to_f
	end
	def total_ascent
		# return ascent in meters
				return @total_ascent
	end
	def total_descent
		# return ascent in meters
				return @total_descent
	end
end
