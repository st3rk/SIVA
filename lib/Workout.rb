class Workout
	def initialize(file)
		# Load the .fit file
		@fit_file = Fit.load_file(ARGV[0])
		# Parse the activity type in the file name
		@activity_type = ARGV[0].gsub(/.*-([^1-9]+[^\.]).fit$/, '\1')
		# Parse the file to define some attributes
		@records = Array.new
		@fit_file.records.each do |r|
			if r.content.record_type == :file_id
				@file_id = FileID.new(r.content)
			elsif r.content.record_type == :record
				@records << Record.new(r.content)
			end
		end
		# Check if this is a type 4 (activity) file
		abort("This is not an activity file") if @file_id.type != 4
		# sum the time of each record
		# time in ms
		@total_time = 0
		@moving_time = 0
		@records.each_with_index do |r, index|
			# ignore the first record
			if index > 0
				# substract previous record timestamp to current timestamp
				# to get relative time value
				@total_time = @total_time + (r.geojson_timestamp - @records[index - 1].geojson_timestamp)
				# sum to moving time if non-null speed
				@moving_time = @moving_time + (r.geojson_timestamp - @records[index - 1].geojson_timestamp) if r.speed_kph > 1
			end
		end
		# total distance is stored in the last record
		@total_distance = @records[-1].distance
	end
	def creation_time
		return @file_id.time
	end
	def track_export(json_file,marker_file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(json_file, file_param) do |geojson|
			File.open(marker_file, file_param) do |marker|
				geojson.print "track = [ {\n\t\"type\": \"FeatureCollection\",\n\t\"features\": [\n\t\t{\n\t\t\t\"type\": \"Feature\",\n\t\t\t\"properties\": {\n\t\t\t\t\"time\": \"#{self.creation_time}\"\n\t\t\t},\n\t\t\t\"geometry\": {\n\t\t\t\t\"type\": \"LineString\",\n\t\t\t\t\"coordinates\": ["
				marker.print "var pos_array = [";
				@records.each do |r|
					# ignore the point if GPS signal was lost
					if r.lng != 179.99999991618097 and r.lat != 179.99999991618097
						geojson.print "\t\t\t\t\t[\n\t\t\t\t\t\t#{r.lng},\n\t\t\t\t\t\t#{r.lat},\n\t\t\t\t\t\t#{r.alt}\t\t\t\t\t]"
						marker.print "[#{r.lat}, #{r.lng}]";
						if r.time != @records[-1].time
							geojson.print ",\n" 
							marker.print ","
						end
					end
				end
				geojson.print "\n\t\t\t\t]\n\t\t\t}\n\t\t}\n\t]\n} ];\n"
				marker.print "];\n"
				marker.print "var start_point = L.marker([#{@records[1].lat}, #{@records[1].lng}]);\n"
				marker.print "var end_point = L.marker([#{@records[-1].lat}, #{@records[-1].lng}], {icon: redIcon});\n"
			end
		end
	end
	def speed_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var speed_array = [";
				@records.each do |r|
					f.print "[#{r.geojson_timestamp}, #{r.speed_kph}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def hr_exists?
		@records.each do |r|
			return true if r.hr != 255
		end
		return false
	end
	def hr_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var hr_array = [";
				@records.each do |r|
					# set it to 0 if it's not available (=255)
					if r.hr != 255
						f.print "[#{r.geojson_timestamp}, #{r.hr}]"
					else
						f.print "[#{r.geojson_timestamp}, 0]"
					end
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def alt_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var alt_array = [";
				@records.each do |r|
					f.print "[#{r.geojson_timestamp}, #{r.alt}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def cadence_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var cadence_array = [";
				@records.each do |r|
					f.print "[#{r.geojson_timestamp}, #{r.cadence}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def temp_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var temp_array = [";
				@records.each do |r|
					f.print "[#{r.geojson_timestamp}, #{r.temp}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def stance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var stance_array = [";
				@records.each do |r|
					# Set stance value to 0 if not available
					if r.stance_time != 65535
						f.print "[#{r.geojson_timestamp}, #{r.stance_time}]"
					else
						f.print "[#{r.geojson_timestamp}, 0]"
					end
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def vertical_osc_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var vertical_osc_array = [";
				@records.each do |r|
					# Set stance value to 0 if not available
					if r.vertical_osc != 65535
						f.print "[#{r.geojson_timestamp}, #{r.vertical_osc}]"
					else
						f.print "[#{r.geojson_timestamp}, 0]"
					end
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def activity_type
		return @activity_type
	end
	def total_time
		# return total time in format HH:MM:SS
		return Time.at(@total_time/1000).utc.strftime("%H:%M:%S")
	end
	def moving_time
		# return moving time in format HH:MM:SS
		return Time.at(@moving_time/1000).utc.strftime("%H:%M:%S")
	end
	def total_distance
		return (@total_distance / 100000).round(3)
	end
	def avg_speed
		# return average speed in km/h
		return ((@total_distance.to_f / 100000) / (@moving_time.to_f / 3600000)).round(2)
	end
end
