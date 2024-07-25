#!/usr/bin/env ruby
#
# Diceware passphrase generator; not as secure as secretly
# rolling actual dice, but a lot more convenient, especially
# if you generate a bunch and pick from the list.

# ruleset is a TOML-format file containing at least two arrays,
# one named 'patterns' and one with a single-character name.
# To generate a passphrase, for each character in a pattern,
# if it's the name of an array, use a random member, otherwise
# insert it literally.

require 'json'
require 'toml-rb'
require 'optparse'
require 'sysrandom'

# for some reason sysrandom doesn't offer a rand() method,
# which prevents it from being used in place of Random for
# things like shuffle()
#
module Sysrandom
	alias_method :random_number, :rand
	module_function :rand
end

def make_pass(pattern,rulesets)
	result=''
	i=0
	pattern.each_char { |char|
		rules = rulesets[i]
		if rules[char]
			len = rules[char].length
			result += rules[char].sample(random: Sysrandom)
			i = (i + 1) % rulesets.length
		else
			result += char
		end
	}
	return result.split(' ')
end

def entropy_calc(pattern,rulesets)
	entropy = 0
	i = 0
	pattern.each_char { |char|
		rules = rulesets[i]
		if rules[char]
			entropy += Math.log(rules[char].length, 2)
			i = (i + 1) % rulesets.length
		end
	}
	if $options[:shuffle] and pattern.split(' ').uniq.length > 1
		entropy += Math.log(pattern.count(' ') + 1, 2)
	end
	return entropy
end

def ruleset_info(r)
	puts "Ruleset: #{r["filename"]}"
	puts "Array Sizes:"
	r.keys.sort.each { |k|
		next if ["patterns", "filename"].include?(k)
		printf("   %s %d\n",k,r[k].length)
	}
	puts "Patterns:"
	i = 1
	r["patterns"].each { |p|
		printf("  %2d (%6.2f): %s\n",i,entropy_calc(p,[r]),p);
		i += 1
	}
end

$options = {
	:count => 10,
	:entropy => false,
	:list => false,
	:pattern => '',
	:shuffle => false,
}
usage = ''
usage2 = <<EOF

The default pattern in the supplied rulesets has at least 80 bits of
entropy. I recommend that you use one of the stronger patterns, and
remember half of it and write the other half on a card in your wallet.

If multiple rulesets are supplied, it will select the pattern from the
first one and then select elements from each ruleset in turn. The
effective entropy is higher than the estimate, especially if you use
the shuffle option.
EOF
OptionParser.new('', 24, '  ') { |opts|
	opts.banner = "Usage: #{$0} [options] ruleset ...\n\n"
	opts.on("-cCOUNT", "--count COUNT",
		"generate COUNT passphrases") { |o|
		$options[:count] = o.to_i
	}
	opts.on("-e", "--entropy",
		"calculate the entropy for the current pattern") {
		$options[:entropy] = true
	}
	opts.on("-l", "--list",
		"list the available patterns in the rulesets") {
		$options[:list] = true
	}
	opts.on("-pPATTERN", "--pattern PATTERN",
		"select a pattern by number, or supply your own") { |o|
		$options[:pattern] = o
	}
	opts.on("-s", "--shuffle",
		"randomly reorder the output words") {
		$options[:shuffle] = true
	}
	opts.on("-h","--help", "show this help text") {
		puts opts.to_s + usage2
		exit 0
	}
	usage = opts.to_s + usage2
}.parse!
if ARGV.length == 0
	puts usage
	$stderr.puts "Error: no ruleset supplied on command line"
	exit 1
end

rulesets = []
ARGV.each { |arg|
	cache="cache/#{arg}"
	if File.exist?(cache) and File.mtime(arg) <= File.mtime(cache)
		ruleset = JSON.load(File.read(cache))
	else
		begin
			ruleset = TomlRB.load_file(arg)
		rescue Exception => e
			$stderr.puts "Error: '#{arg}': #{e.message}"
			exit 1
		end
		ruleset["filename"] = arg
		File.open(cache, 'wb') {|f| f.write(JSON.dump(ruleset))}
	end
	rulesets.push(ruleset)
}

if $options[:list]
	rulesets.each { |r|
		ruleset_info(r)
		puts
	}
	puts "Random printable ASCII passwords (6.57 bits/char):"
	[8, 10, 12, 14, 16, 18].each { |l|
		printf("  %2d=%.2f", l, l * Math.log(95, 2))
	}
	puts
	exit 0
end

patterns = rulesets[0]["patterns"]
pattern = patterns[0]
if $options[:pattern].empty? == false
	if $options[:pattern].match?(/^\d+$/)
		if (1..patterns.length) === $options[:pattern].to_i
			pattern = patterns[$options[:pattern].to_i - 1]
		else
			puts usage
			$stderr.puts "Error: pattern #{$options[:pattern]} out of range"
			exit 1
		end
	else
		pattern = $options[:pattern]
	end
end

entropy = entropy_calc(pattern,rulesets)
(1..$options[:count]).each { |i|
	printf("%7.2f\t",entropy) if $options[:entropy]
	out = make_pass(pattern,rulesets)
	out.shuffle!(random: Sysrandom) if $options[:shuffle]
	puts out.join(' ')
}
exit 0
