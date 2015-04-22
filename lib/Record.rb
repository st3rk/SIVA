class Record
	def initialize(record)
		@timestamp = record[:raw_timestamp]
		@lat = record[:raw_position_lat]
		@long = record[:raw_position_long]
		@distance = record[:raw_distance]
		@altitude = record[:raw_altitude]
		@speed = record[:raw_speed]
		@power = record[:raw_power]
		@vertical_osc = record[:raw_vertical_oscillation]
		@stance_time_percent = record[:raw_stance_time_percent]
		@stance_time = record[:raw_stance_time]
		@hr = record[:raw_heart_rate]
		@cadence = record[:raw_cadence]
		@cyclelength = record[:raw_cycle_length]
		@temp = record[:raw_temperature]
		@lr_balance = record[:raw_left_right_balance]
		@fract_cadence = record[:raw_fractional_cadence]
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
	def lat
		# convert semicircles to degres
		# formula : deg = semicircles * 180 / 2^31
				return @lat.to_f * 180.to_f / 2147483648.to_f
	end
	def lng
		# convert semicircles to degres
		# formula : deg = semicircles * 180 / 2^31
				return @long.to_f * 180.to_f / 2147483648.to_f
	end
	def alt
		# converte altitude to meters
		# fit altitude is in units of 1/5m with an offset of 500m
				return (@altitude.to_f / 5.to_f - 500.to_f).round(1)
	end
	def hr
		return @hr
	end
	def speed
		# speed in mm/s
		return @speed
	end
	def speed_kph
		# speed in km/h
		if @speed < 65535
			return (@speed.to_f/1000000.to_f*3600.to_f).round(2)
		else
			return 0
		end
	end
	def cadence
		return @cadence
	end
	def temp
		return @temp
	end
	def stance_time
		return @stance_time
	end
	def vertical_osc
		return @vertical_osc
	end
	def distance
		return @distance.to_f.round(3)
	end
end
