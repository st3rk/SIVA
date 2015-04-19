class FileID
	def initialize(message)
		@serial = message[:raw_serial_number]
		@timestamp = message[:raw_time_created]
		@manufacturer = message[:raw_manufacturer]
		@product = message[:raw_product]
		@number = message[:raw_number]
		@type = message[:raw_type]
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
	def type
		return @type
	end
end
