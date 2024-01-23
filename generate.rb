#!/usr/bin/env ruby
#coding:utf-8

require 'rubygems'
require "prawn"
require "prawn-svg"
require 'yaml'

def produce_cv(data, output_filename)
	Prawn::Document.generate(output_filename, top_margin: 75 + 36 * 2) do

		font_families.update("DejaVu Sans" => {
			:normal => "assets/DejaVuSans.ttf"
		})

		font "DejaVu Sans"
		default_leading 3

		repeat(:all, dynamic: true) do
			canvas do
      	bounding_box([bounds.left + 36, bounds.top - 50], :height => 75, width: bounds.right - 36 * 2) do
        	svg(File.read("assets/val_logo.svg"), :at => [bounds.right - 50, bounds.top], :width => 50)
        	bounding_box([bounds.right - 240 , bounds.top - 5], :width => 180, :height => 50) do
						fill_color "222222"

						font_size 12
						text "Valentin Arkhipov", :align => :right
						font_size 10
						text "arkhipov.valentin@gmail.com\n+49 177 5998891", :align => :right
					end

					fill_color "999999"

					if page_number == 1
						font_size 20
						text "Curriculum vitae"
					end

					if page_number > 1
						font_size 10
						text "Page #{page_number}"
					end

					stroke do
						stroke_color "dddddd"
						horizontal_rule
					end

      	end
 			end


		end

		def print_section(section, level, index)
			title_size = 16 - (level * 4)
			indent = 10 + (level * 20)
			if section['content'].is_a?(Array)
				indent(indent) do
					move_down 20
					font_size title_size
					fill_color "777777"
					text section['title']
				end

				section['content'].each_with_index do |sub_section, index|
					print_section(sub_section, level + 1, index)
				end
			else
				if section['start_new_page']
					start_new_page
				end
				indent(indent) do
					move_down 20
					
					font_size title_size
					fill_color level == 0 ? "777777" : "000000"
					text section['title']

					# First section of first level? Add a photo!
					if (level == 0) && (index == 0)
						image "assets/Valentin Arkhipov.jpg", :at => [bounds.right - 200 , bounds.top - 50], :width => 200
					end

					unless section['introduction'] == ''
						move_down 5
						font_size 10
						fill_color "999999"
						text section['introduction']
					end

					move_down 5
					font_size 10
					fill_color "333333"
					
					# First section of first level? Share space with photo!
					span_width = if (level == 0) && (index == 0)
						290
					else
						500
					end
					span span_width do
						text section['content'], :inline_format => true
					end
				end
			end
		end

		data['sections'].each_with_index do |section, index|
			print_section(section, 0, index)
		end

	end
end


data_filename = 'data.yaml'
unless File.exists? data_filename
	puts "Cant locate file #{data_filename}"
	exit 1
end

output_filename = File.join('cv.pdf')
# Overwrite
# if File.exists? output_filename
# 	puts "Output file #{output_filename} already exists"
# 	exit 1
# end

data = YAML.load(File.read(data_filename))
produce_cv(data, output_filename)
