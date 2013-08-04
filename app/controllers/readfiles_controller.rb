require 'csv'

class ReadfilesController < ApplicationController
	def index
		@lines = []
		if !params[:lookup].nil?
			begin
				@lines = open(params[:lookup])
			rescue NoFileSelectedException, NoSuchFileException, NotCsvTypeException => e
   			@lines.push("Uploaded File Error: #{e}")
			end
		end
	end

	#####################
	# @arg: filename
	# @return: array of file content
	#
	# Take in `filename` path, check file existency,
	# validity and then get valid info out of it
	#####################
	def open(file_name)
		#############################################
		# Should not be hard-coded, hard-code only for local test
		# Here is hard coded filepath
		#filename = "UPLOADFILES/matcha.csv"
		file_directory = 'UPLOADFILES/'

		raise NoFileSelectedException if file_name.empty?

		file_name = file_directory + file_name

		raise NoSuchFileException if !File.exist?(file_name)
		raise NotCsvTypeException if File.extname(file_name) != '.csv'

		file_content = []
		CSV.foreach(file_name) do |row|
			file_content.push(row)
		end

		begin
			@lines = get_lines_infos(file_content)
    rescue CsvFileException, NameColMissingException => e
      ##############################
			# Catch exception and handle
			@lines = []
			@lines.push("Unsuccessful Update database: #{e}")
  	end

		update_table(file_name, @lines)
  	return @lines
	end

	#####################
	# @arg: lines
	# @return: array of lines info
	#
	# Take in `lines` array, check info and extract them out
	#####################
	def get_lines_infos(lines)

		head = ''
		col_name = Array.new(lines[0])

		lines[0].each do |item|
			( item.nil? ) ? head : (head << item.strip)
		end
		col_size = lines[0].size

		raise NameColMissingException if head.size<col_size

		valid_col = []

		col_size.times do |i|
			( col_name[i].nil? ) ? (col_name[i] = '') : (col_name[i] = col_name[i].strip)
			( col_name[i].empty? ) ? valid_col : valid_col.push(i)
		end

 		return_lines = []

 		line = 'ColName:'
 		valid_col.each do |i|
 			line << col_name[i] + ','
 		end

 		return_lines.push(line)

 		lines.each do |l|
 			line = ''
 			valid_col.each do |i|
 				(l[i].nil? ) ? line << '[++]' : line << l[i].strip + '[++]'
 			end
 			return_lines.push(line)
 		end

 		return return_lines
	end

	###################
	# This function is for testing
	# Functions for table: Post
	# title => string
	# text => text
	# timestamps:
	# 	created_at => date
	# 	updated_at => date
	###################
	def update_table(file_name, lines)

		# Identify which table the infomation goes
		# Identify the datatype if it fits the database
		# Create the correct controller
		# Create the correct hash, according to the datatype
		content = { title: file_name, text: lines }

		#controller = PostsController.new
		#controller.update_db(content)

		controller = CommentsController.new
		controller.update_db(content)
	end
	###################
	###################

end

class NoFileSelectedException < Exception
	# Empty Body, used to define exception
end

class NoSuchFileException < Exception
	# Empty Body, used to define exception
end

class NotCsvTypeException < Exception
	# Empty Body, used to define exception
end

class CsvFileException < Exception
	# Empty Body, used to define exception
end

class NameColMissingException < Exception
	# Empty Body, used to define exception
end
