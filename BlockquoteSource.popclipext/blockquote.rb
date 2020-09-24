#!/usr/bin/ruby

require_relative './html2text'

if ARGV[0] =~ /\-?d(ebug)?/
	input = STDIN.read
	# ENV['POPCLIP_MODIFIER_FLAGS'] = 1048576.to_s
else
	input = ENV['POPCLIP_HTML']
	source_title = ENV['POPCLIP_BROWSER_TITLE']
	source_url = ENV['POPCLIP_BROWSER_URL']
end

encoding = "utf-8"
data = data.decode(encoding)
h = HTML2Text()
h.ul_item_mark = '-'
h.body_width = 0
h.list_indent = 36
h.ignore_emphasis = False
h.ignore_links = False
h.ignore_images = True
h.google_doc = True
h.hide_strikethrough = False

input = wrapwrite(clean_invisibles(input))

def trailing_whitespace(input)
	out = []
	input.reverse.each {|line|
		if line =~ /^([\s\t])*$/
			out.push("#{$1}")
		else
			break
		end
	}
	out.reverse.join("\n")
end

def quote_block(input)
	while input[-1] =~ /^\s*$/
		input.pop
	end
	output = ""
	input.each do |line|
		quote = ">"
		tabs = line.match(/^([\s\t]+)/)

		unless tabs.nil?
			count = tabs[1].gsub(/\t/,"    ").length / 4
			count.times do
				quote += " >"
			end
		end

		# don't quote reference definitions
		unless line =~ /^\s*\[.*?\]: .*/
			output += line =~ /^\s*$/ ? "#{quote}\n" : "#{quote} #{line.sub(/^[\s\t]*/,'')}\n"
		else
			output += line
		end
	end
	output.sub(/\s+$/,'')
end

trail_match = input.match(/(?i-m)[\s\n\t]++$/)
trailing = trail_match.nil? ? "" : trail_match[0]

input = input.split("\n")
output = []

source = ''
unless source_url.empty?
	if source_title.empty?
		source_title = source_url
	end

	source = ">\n" + '> -- [' + source_title +'](' + source_url + ')'
end


case ENV['POPCLIP_MODIFIER_FLAGS'].to_i
when 1048576 # Command (remove one level of blockquoting)
	input.each do |line|
		output.push(line.sub(/^(\s*)>\s*/,'\1'))
	end
	output.push(source) unless source.empty?
when 1572864 # Option-Command (remove all blockquoting)

	input.each do |line|
		output.push(line.sub(/^(\s*)(>\s*)*/,'\1'))
	end
	output.push(source) unless source.empty?
else # Increase quote level by one
	block = []
	skipping = false
	input.each_with_index do |line, i|
		block.push(line)
	end
	output.push(quote_block(block)) unless block.empty?
	output.push(source) unless source.empty?
end

print output.join("\n") + trailing #.sub(/\n$/s,'')

