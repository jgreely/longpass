#!/usr/bin/env ruby
#
# generate a list of Japanese words from JMdict, using the same
# priority tags that are used when generating Edict. Default output
# is for my pass script; use "-d" to generate an actual 5-dice
# Diceware list (randomly selecting 7776 unique words from the
# output). Skips short, long, and katakana words, leaving around
# 9,700 unique romanized strings.

require 'Nokogiri'
require 'nori'
require 'romajify/converter'

# implement a force_arrays option like Perl's XML::Twig::simplify()
#
def force_arrays(node, arrays)
	if node.is_a?(Hash)
		node.each { |k,v|
			force_arrays(v, arrays)
			if arrays.include?(k) and !v.is_a?(Array)
				node[k] = [v]
			end
		}
	elsif node.is_a?(Array)
		node.each { |n|
			force_arrays(n, arrays)
		}
	end			
end

$PRI = %w[ichi1 news1 spec1 spec2]
def parse_entry(node)
	node = node["entry"]
	force_arrays(node, %w[k_ele ke_pri r_ele re_pri])
	result = []
	# if any of the kebs are popular, assume the first reb is, too
	pop_k = false
	if node["k_ele"]
		node["k_ele"].each { |k|
			if k["ke_pri"] and (k["ke_pri"] & $PRI) != []
				pop_k = true
			end
		}
	end
	r_ele = node["r_ele"]
	if pop_k
		first = r_ele.shift
		result.push(first["reb"])
		pop_k = false
	end
	r_ele.each { |r|
		if r["re_pri"] and (r["re_pri"] & $PRI) != []
			result.push(r["reb"])
		end
	}
	return result
end

def make_diceware(dice,words)
	words = words.uniq.shuffle.slice(0,6**dice).sort
	rolls = %w[1 2 3 4 5 6].repeated_permutation(dice).map{ |a|
		a.join('')
	}.sort.each { |r|
		puts "#{r}\t#{words.shift}"
	}
end


options = Nokogiri::XML::ParseOptions.new.noent # must substitute entities
jmdict = Nokogiri::XML::Reader(File.open("Jmdict_e"), nil, nil, options)
nori = Nori.new

popular = []
jmdict.each { |node|
	if node.name == "entry" and
			node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
		popular.push(parse_entry(nori.parse(node.outer_xml)))
	end
}

words = []
popular.flatten.each { |w|
	next if w =~ /\p{Katakana}/
	w = Romajify::Converter.hepburn(w, {:traditional => 1})
	next if w.length < 3 or w.length > 7
	words.push(w)
}

if ARGV[0] == "-d"
	make_diceware(5,words)
	exit
end

puts <<EOF;
patterns = [
	"a a a a a a vsd",
	"a a a a a a a a vsd",
	"a a a a a a a vsd",
	"a a a a a vsd",
	"a a a a vsd",
	"a a a a a a a a",
	"a a a a a a a",
	"a a a a a a",
	"a a a a a",
	"a a a a",
]

d = [
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
]

s = [
	"+", "-", "*", "/",
]

v = [
	"A", "B", "C", "K", "N", "Q", "T", "X", "Y", "Z",
]

a = [
EOF

words.uniq.sort.each { |w|
	puts %Q("#{w}",)
}
puts "]"
exit 0
