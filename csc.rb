#!/usr/bin/env ruby
require 'raspell' 

class CommentSpellCheck
  SP = Aspell.new("en") #initialize our spell checker
  SP.suggestion_mode = Aspell::NORMAL
  SP.set_option("ignore-case", "false") #case sensitivity is important to us

  #regex to find text within documentation code comments, not plain // comments or regular block comments /* */. Only /** */ comments
  @@comment_regex    = /\/\*\*([\w\d\W\D]+?)\*\//
  #list of words we can safely ignore as language constructs, language keywords, jargon, or documentation keywords 
  @@ignored_words    = ['struct', 'iOS', 'rect', 'param']

  #find all the misspellings and potential errors in a file
  def self.misspelledWords(string, path)
  	#store all the wrong words and potential errors
  	wrongWords = Array.new
  	probablySpeltRight = Array.new
  	#determine what file we are in by getting the last element of the path when split by forward slashes
  	filename = path.split('/')[-1]

  	#split the file by the comment finding regex
  	string.scan(@@comment_regex) {|comment|
  		for line in comment #find each line of a comment
  			for word in line.split(' ') #find each word of a line of a comment
  				word.gsub!(/([\W\d]+)/, '') #cut out non-word and numeric characters
  				#I sure hope you don't use numbers in your variable names!!!
  				word.strip! #strip out any whitespace, just in case

  				#iterate through the list of ignoreable words and ignore any ones we meet
  				@@ignored_words.each { |ignoreMe| 
  					if word == ignoreMe
  						word = ''
  					end
  				}

  				#a camel case word is probably okay to ignore
  				# being a variable or other programming construct
				if hasInnerCapital(word)
					#add to list of probably safely ignored
					#add the filename to the warned word indenting it first
					probablySpeltRight << "\e[33m" + word + "\e[0m" + "\t in #{filename}"
					next
				end

				#check if this word is: spelled wrong, ascii characters only, 
				# not a word with >2 capitals in a row signifying an Objective-C
				# namespace prefixed construct, and not equal to the empty string
	  		    if isValidWord(word) #switch this to `word.isValidWord?`
	  		    	#add the filename to the misspelled word indenting it first
  		    		wrongWords << "\e[31m" + word + "\e[0m" + "\t in #{filename}"
		  	    end
		  	end
  		end
  	}

  	#make sure that each element only occurs once and return the errors and warnings
	return wrongWords.uniq, probablySpeltRight.uniq 
  end

  #check if this word is: spelled wrong, ascii characters only, 
  # not a word with >2 capitals in a row signifying an Objective-C
  # namespace prefixed construct, and not equal to the empty string
  def self.isValidWord string
  	return (!SP.check(string) and string.ascii_only? and !hasObjective_CNamePrefix(string)  and string != '')
  end

  #check if this string begins with two or more capitals
  # which signifies that it is a string with an Objective-C
  # namespace prefix, we ignore these
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
  	return false
  end

  #check if there is an inner capitalization: exampleString
  #  which are often used in variables
  #  used to put matches in potential errors list
  def self.hasInnerCapital string
  	result = string.scan(/([a-z]+[A-Z]+[a-z]+)/)
  	if result.count == 1
  		return true
  	else
  		return false
  	end
  end

  # Given a directory, it will scan it for all .h files and spell check comments 
  def self.spellCheck(path = nil)
    if path
      path = File.expand_path(path)
      allObjCFiles = Dir.glob(path + '/**/*.h') #recursively search path and subdirectories
    else
      allObjCFiles = Dir.glob('**/*.h') #recursively search present directory
    end

    #store the results of each file's spell check split into errors and warnings
    errors = Array.new
    potentialErrors = Array.new

    #iterate through each file
    allObjCFiles.each { |path| 
      #read the file
      input = File.open(path, 'r')
      text = input.read

      #calculate misspellings and potential misspellings
      #  don't worry about duplicates or empty strings 
      #  as `misspelledWords() takes care of them
      misspellings, probablyRight = self.misspelledWords(text, path)
		errors << misspellings
		potentialErrors << probablyRight
     
      input.close
    }

    if errors.count > 0
	    #color Errors red, print each error
	    puts "\e[1mSpelling Errors:\e[0m"
	    errors.each {|error|
	    	puts error
	    }
	else 
		puts "\e[1mNo errors! :D\e[0m"
	end

	if potentialErrors.count > 0
	    #color Warnings yellow, print each warning
	    puts "\e[1mSpelling Warnings:\e[0m"
	    potentialErrors.each {|perror|
		    puts perror
		}
	else
		puts "\e[1mNo warnings! :D\e[0m"
	end
  end
end

path = ARGV[0]
if path
	CommentSpellCheck.spellCheck(path)
else
	CommentSpellCheck.spellCheck('.')
end