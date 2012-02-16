#!/usr/bin/env ruby
require 'rubygems'
require 'raspell'

class CommentSpellCheck
  SP = Aspell.new("en")
  SP.suggestion_mode = Aspell::NORMAL
  SP.set_option("ignore-case", "false")

  # For an explanation of the regex algorithm visit http://stackoverflow.com/a/8947861/178805
  @@comment_regex    = /\/\*\*([\w\d\W\D]+?)\*\//
  @@ignored_words    = ['struct', 'iOS', 'rect', 'param']

  def self.misspelledWords(string, path, indent = '')
  	newline = "\n"

  	wrongWords = Array.new
  	lineNumber = 0

  	filename = path.split('/')[-1]

  	# for line in string.scan(@@comment_regex)
  	string.scan(@@comment_regex) {|comment|
  		for line in comment
  			for word in line.split(' ')
  				word.gsub!(/([\W\d]+)/, '')

  				# if hasObjective_CNamePrefix(word)
  				# 	continue
  				# end

  				@@ignored_words.each { |ignoreMe| 
  					if word == ignoreMe
  						word = ''
  					end
  				}

	  		    if !SP.check(word and word.ascii_only? and !hasObjective_CNamePrefix(word) and word != ''
				  wrongWords << "In #{filename}: #{word}" + newline
				  wrongWords << newline
		  	    end
		  	end
  		end
  	}
  	
	return wrongWords
  end

  def self.hasObjective_CNamePrefix string
  	capsCount = 0
  	for letter in string.each_char
  		if letter.upcase == letter
  			capsCount += 1
  			if capsCount > 2
  				return true
  			end
  		else
  			return false
  		end
  	end
  end

  # Given a directory, it will scan it for all .h files and spell check comments 
  def self.spellCheck(path = nil)
    if path
      path = File.expand_path(path)
      allObjCFiles = Dir.glob(path + '/**/*.h')
    else
      allObjCFiles = Dir.glob('**/*.h')
    end

    errors = Array.new

    allObjCFiles.each { |path| 
      input = File.open(path, 'r')
      text = input.read
      errors << self.misspelledWords(text, path, "	 ")
      input.close
    }

    return errors.join(' ')
  end
end

# fileToExamine = File.open('/Users/Joe/Desktop/UIDevice+DTVersion.h', 'r')
# text = fileToExamine.read

# out = File.open('out.txt', 'w')

# out.write(CommentSpellCheck.misspelledWords(text))

# out.close
# fileToExamine.close


path = ARGV[0]
result = CommentSpellCheck.spellCheck(path)

path = File.expand_path(path)
path += "/commentspellcheck_output.txt"
output = File.open(path, 'w+')
output.write(result)
output.close

