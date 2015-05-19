require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib Record.rb]))
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib Session.rb]))
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib FileID.rb]))

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
			elsif r.content.record_type == :session
				@session = Session.new(r.content)
			end
		end
		# Check if this is a type 4 (activity) file
		abort("This is not an activity file") if @file_id.type != 4
		# sum the time of each record
		# time in ms
		@total_time = 0
		@moving_time = 0
		@total_hr = 0
		@total_cadence = 0
		@total_stance = 0
		@total_vertical_osc = 0
		@max_speed = 0
		@max_hr = 0
		@records.each_with_index do |r, index|
			# ignore the first record to compute the relative time
			if index > 0
				# substract previous record timestamp to current timestamp
				# to get relative time value
				relative_time = r.geojson_timestamp - @records[index - 1].geojson_timestamp
				# if distance is null, but GPS location is valid, try to compute it with Haversine formula
				if r.distance == 0 and r.lng != 179.99999991618097 and r.lat != 179.99999991618097 and @records[index - 1].lng != 179.99999991618097 and @records[index - 1].lat != 179.99999991618097
					haversine_distance = self.haversine(@records[index -   1].lat, @records[index -   1].lng, r.lat, r.lng)
					# if distance was actually not null, fix it and recompute speed
					if haversine_distance != 0
						r.set_distance(haversine_distance)
						puts haversine_distance
						#speed in m/s
						r.set_speed(haversine_distance,relative_time)
					end
				end
				# compute total time
				@total_time = @total_time + relative_time
				# sum to moving time if non-null speed
				@moving_time = @moving_time + relative_time if r.speed_kph > 1
				# compute total hr
				@total_hr = @total_hr + (r.hr * relative_time)
				# compute total cadence
				@total_cadence = @total_cadence + (r.cadence * relative_time)
				# compute total stance
				@total_stance = @total_stance + (r.stance_time * relative_time)
				# compute total vertical_osc
				@total_vertical_osc = @total_vertical_osc + (r.vertical_osc * relative_time)
				# store maximum speed
				@max_speed = r.speed_kph if r.speed_kph > @max_speed
				# store maximum heart rate
				@max_hr = r.hr if r.hr > @max_hr and r.hr < 255
			end
		end
		# total distance is stored in the last record
		@total_distance = @records[-1].distance
		# 
		@total_distance = @records[-1].distance
	end
	# The Haversine formula used to compute the distance between two points
	def haversine(lat1, long1, lat2, long2)
		dtor = Math::PI/180
		r = 6378.14*1000
		
		rlat1 = lat1 * dtor
		rlong1 = long1 * dtor
		rlat2 = lat2 * dtor
		rlong2 = long2 * dtor
		
		dlon = rlong1 - rlong2
		dlat = rlat1 - rlat2
		
		a = ((Math::sin(dlat/2)) ** 2) + Math::cos(rlat1) * Math::cos(rlat2) * ((Math::sin(dlon/2)) ** 2)
		c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
		d = r * c
		
		return d
	end
	def creation_time
		return @file_id.time
	end
	# export the location point in json
	def track_export(json_file,marker_file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(json_file, file_param) do |geojson|
			File.open(marker_file, file_param) do |marker|
				geojson.print "track = [ {\n\t\"type\": \"FeatureCollection\",\n\t\"features\": [\n\t\t{\n\t\t\t\"type\": \"Feature\",\n\t\t\t\"properties\": {\n\t\t\t\t\"time\": \"#{self.creation_time}\"\n\t\t\t},\n\t\t\t\"geometry\": {\n\t\t\t\t\"type\": \"LineString\",\n\t\t\t\t\"coordinates\": ["
				marker.print "var pos_array = [";
				first_point_index = nil
				last_point_index = nil
				@records.each_with_index do |r,index|
					# find first and last valid gps point index
					first_point_index = index if first_point_index == nil and r.lng != 179.99999991618097 and r.lat != 179.99999991618097
					last_point_index = index if r.lng != 179.99999991618097 and r.lat != 179.99999991618097
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
				# write markers for first and last valid gps point
				marker.print "var start_point = L.marker([#{@records[first_point_index].lat}, #{@records[first_point_index].lng}]);\n"
				marker.print "var end_point = L.marker([#{@records[last_point_index].lat}, #{@records[last_point_index].lng}], {icon: redIcon});\n"
			end
		end
	end
	def speed_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var speed_array = [";
				@records.each do |r|
					# substract first record timestamp to get relative time
					f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, #{r.speed_kph}]"
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
					# substract first record timestamp to get relative time
						f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, #{r.hr}]"
					else
						f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, 0]"
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
					# substract first record timestamp to get relative time
					f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, #{r.alt}]"
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
					# substract first record timestamp to get relative time
					f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, #{r.cadence}]"
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
					# substract first record timestamp to get relative time
					f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, #{r.temp}]"
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
					# substract first record timestamp to get relative time
						f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, #{r.stance_time}]"
					else
						f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, 0]"
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
					# substract first record timestamp to get relative time
						f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, #{r.vertical_osc}]"
					else
						f.print "[#{r.geojson_timestamp - @records[0].geojson_timestamp}, 0]"
					end
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def speed_distance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var speed_distance_array = [";
				@records.each do |r|
					# substract first record timestamp to get relative time
					f.print "[#{(r.distance.to_f / 100000).round(3)}, #{r.speed_kph}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def hr_distance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var hr_distance_array = [";
				@records.each do |r|
					# set it to 0 if it's not available (=255)
					if r.hr != 255
					# substract first record timestamp to get relative time
						f.print "[#{(r.distance.to_f / 100000).round(3)}, #{r.hr}]"
					else
						f.print "[#{(r.distance.to_f / 100000).round(3)}, 0]"
					end
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def alt_distance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var alt_distance_array = [";
				@records.each do |r|
					# substract first record timestamp to get relative time
					f.print "[#{(r.distance.to_f / 100000).round(3)}, #{r.alt}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def cadence_distance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var cadence_distance_array = [";
				@records.each do |r|
					# substract first record timestamp to get relative time
					f.print "[#{(r.distance.to_f / 100000).round(3)}, #{r.cadence}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def temp_distance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var temp_distance_array = [";
				@records.each do |r|
					# substract first record timestamp to get relative time
					f.print "[#{(r.distance.to_f / 100000).round(3)}, #{r.temp}]"
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def stance_distance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var stance_distance_array = [";
				@records.each do |r|
					# Set stance value to 0 if not available
					if r.stance_time != 65535
					# substract first record timestamp to get relative time
						f.print "[#{(r.distance.to_f / 100000).round(3)}, #{r.stance_time}]"
					else
						f.print "[#{(r.distance.to_f / 100000).round(3)}, 0]"
					end
					f.print "," if r.time != @records[-1].time
				end
				f.print "];\n"
		end
	end
	def vertical_osc_distance_export(file,file_param)
		abort("#{file_param}: should be \"a\" or \"w\"") if ((file_param != 'a') and (file_param != 'w'))
		File.open(file, file_param) do |f|
			f.print "var vertical_osc_distance_array = [";
				@records.each do |r|
					# Set stance value to 0 if not available
					if r.vertical_osc != 65535
					# substract first record timestamp to get relative time
						f.print "[#{(r.distance.to_f / 100000).round(3)}, #{r.vertical_osc}]"
					else
						f.print "[#{(r.distance.to_f / 100000).round(3)}, 0]"
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
		return ((@total_distance.to_f / 100000) / (@total_time.to_f / 3600000)).round(2)
	end
	def avg_moving_speed
		# return average speed in km/h
		return ((@total_distance.to_f / 100000) / (@moving_time.to_f / 3600000)).round(2)
	end
	def total_ascent
		return @session.total_ascent
	end
	def total_descent
		return @session.total_descent
	end
	def avg_hr
		# average hr is total hr / time unit
		return @total_hr / @total_time
	end
	def avg_cadence
		# average cadence is total hr / time unit
		return @total_cadence / @total_time
	end
	def avg_stance
		# average stance is total hr / time unit
		return @total_stance / @total_time
	end
	def avg_vertical_osc
		# average vertical_osc is total hr / time unit
		return @total_vertical_osc / @total_time
	end
	def max_speed
		return @max_speed
	end
	def max_hr
		return @max_hr
	end
	def min_hr
		return @min_hr
	end
end
