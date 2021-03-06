#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'pp'
require 'date'
require 'fit'
require 'fileutils'
require 'erb'
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib Workout.rb]))

# directory where the workouts will be saved
workouts_dir = "~/workout"

workouts_dir = File.expand_path(workouts_dir)
root = File.expand_path(File.join(File.dirname(__FILE__), %w[..]))

if ((ARGV.length != 1) or (ARGV.length != 2)) and (ARGV[0] !~ /.*\.fit$/)
	puts "Usage: #{$0} <fit_file>"
else
	# ensure the flot files exist
	abort("Please clone the flot repository:\ncd #{root}/data/js && git clone https://github.com/flot/flot.git && cd -") if !(File.exists?("#{root}/data/js/flot"))
	# ensure destination directory and the mandatory filetree exist
	if !(File.exists?(workouts_dir))
		puts "Creating #{workouts_dir}"
		Dir.mkdir(workouts_dir)
	end
	FileUtils.copy_entry("#{root}/data/css", "#{workouts_dir}/css") if !(File.exists?("#{workouts_dir}/css"))
	FileUtils.copy_entry("#{root}/data/js", "#{workouts_dir}/js") if !(File.exists?("#{workouts_dir}/js"))
	FileUtils.copy_entry("#{root}/data/images", "#{workouts_dir}/images") if !(File.exists?("#{workouts_dir}/images"))

	# check if a suffix was given as argument
	ARGV.length == 2 ? (suffix = ARGV[1]) : (suffix = nil)
	
	# define the page title
	if suffix == nil
		title = "#{File.basename(ARGV[0]).gsub(/\.fit$/, "")}"
	else
		title = "#{File.basename(ARGV[0]).gsub(/\.fit$/, "")}_#{suffix}"
	end

	# create the working dir
	dir = "#{workouts_dir}/#{title}"
	abort("The directory #{dir} already exists") if File.exist?(dir)
	Dir.mkdir(dir)

	# copy the fit file
	FileUtils.cp(ARGV[0], "#{dir}/")

	# compute
	workout = Workout.new(ARGV[0])
	workout.track_export("#{dir}/geojson_track.js", "#{dir}/data_array.js", 'w')
	workout.speed_export("#{dir}/data_array.js", 'a')
	workout.hr_export("#{dir}/data_array.js", 'a')
	workout.alt_export("#{dir}/data_array.js", 'a')
	workout.cadence_export("#{dir}/data_array.js", 'a')
	workout.temp_export("#{dir}/data_array.js", 'a')
	workout.stance_export("#{dir}/data_array.js", 'a')
	workout.vertical_osc_export("#{dir}/data_array.js", 'a')
	workout.speed_distance_export("#{dir}/data_array.js", 'a')
	workout.hr_distance_export("#{dir}/data_array.js", 'a')
	workout.alt_distance_export("#{dir}/data_array.js", 'a')
	workout.cadence_distance_export("#{dir}/data_array.js", 'a')
	workout.temp_distance_export("#{dir}/data_array.js", 'a')
	workout.stance_distance_export("#{dir}/data_array.js", 'a')
	workout.vertical_osc_distance_export("#{dir}/data_array.js", 'a')

	# output index.html
	index_template = File.open(File.expand_path(File.join(File.dirname(__FILE__), %w[.. data index.html.erb])), 'r').read
	index_render = ERB.new(index_template)
	File.open(dir + '/index.html', 'w+') { |file| file.write(index_render.result(binding)) }
	puts workout.activity_type
end
exit
