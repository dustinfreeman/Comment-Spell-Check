#!/usr/bin/env ruby
require 'raspell' 

# Universal list of words we can safely ignore as 
# language constructs, language keywords, jargon, or documentation keywords 
$ignored_words = ['struct', 'iOS', 'rect', 'param', 'func']

class CommentSpellCheck
  SP = Aspell.new("en") 
  SP.suggestion_mode = Aspell::NORMAL
  SP.set_option("ignore-case", "false")

  # Regex to find text within documentation code comments, 
  # not plain // comments or regular block comments /* */. 
  # Only /** */ comments
  @@comment_regex = /\/\*([\w\d\W\D]+?)\*\//
 
  # Find all the misspellings and potential errors in a file
  def self.misspelledWords(string, path)
    # Store all the wrong words and potential errors
    wrongWords = Array.new
    probablySpeltRight = Array.new
    # Determine what file we are in by getting the last element of the path when split by forward slashes
    filename = path.split('/')[-1]

    # Split the file by the comment finding regex
    string.scan(@@comment_regex) { |comment|
      for line in comment 
        for word in line.split(' ') 
          word.gsub! /([\W\d]+)/, '' # Cut out non-word and numeric characters
          word.strip! 


          if $ignored_words.include? word
            word = ''
            break
          end

          # Iterate through the list of ignoreable words and ignore any ones we meet
          # $ignored_words.each { |ignoreMe| 
          #   if word == ignoreMe
          #     word = ''
          #         break
          #       end
          # }
        
          first_suggestion = SP.suggest(word)[0]
          second_suggestion = SP.suggest(word)[1]

          # A camel case word is probably okay to ignore
          #  being a variable or other programming construct
          if hasInnerCapital(word)
            # Add to list of probably safely ignored
            # Add the filename to the warned word indenting it first
            item = "\e[33m" + word + "\e[0m" + "\t in #{filename}"
            if first_suggestion != nil
              item += "\n did you mean \e[32m#{first_suggestion}\e[0m or \e[32m#{second_suggestion}\e[0m?"
            end

            probablySpeltRight << item

            next
          end

          # Check if this word is: spelled wrong, ascii characters only, 
          #  not a word with >2 capitals in a row signifying an Objective-C
          #  namespace prefixed construct, and not equal to the empty string
          
          if isValidWord(word) # Switch this to `word.isValidWord?`
            # Add the filename to the misspelled word indenting it first
            item = "\e[31m" + word + "\e[0m" + "\t in #{filename}" 
            if first_suggestion != nil
              item += "\n did you mean \e[35m#{first_suggestion}\e[0m or \e[35m#{second_suggestion}\e[0m?"
            end

            wrongWords << item
          end
        end
      end
    }

    # Make sure that each element only occurs once and return the errors and warnings
    return wrongWords.uniq, probablySpeltRight.uniq 
  end

  # Check if this word is: spelled wrong, ascii characters only, 
  #  not a word with >2 capitals in a row signifying an Objective-C
  #  namespace prefixed construct, and not equal to the empty string
  def self.isValidWord string
    return (!SP.check(string) && string.ascii_only? && !hasObjective_CNamePrefix(string)  && string != '')
  end

  # Check if this string begins with two or more capitals
  #  which signifies that it is a string with an Objective-C
  #  namespace prefix, we ignore these
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

  # Check for CamelCase
  def self.hasInnerCapital string
    result = string.scan(/([a-z]+[A-Z]+[a-z]+)/)
    if result.count == 1
      return true
    else
      return false
    end
  end

  # Given a directory, it will scan it for all .h files and spell check comments 
  def self.spellCheck(path, ignoreFile)
    # Load a text file of other words to ignore and append it to class list of ignored words
    if ignoreFile      
      importedIgnoreFile = File.open(ignoreFile, 'r')
      userIgnore = importedIgnoreFile.read.split("\n")
      
      $ignored_words << userIgnore
      $ignored_words.flatten!
      importedIgnoreFile.close
      print 'Ignoring extended: '
      $ignored_words.map { |e| print e, ', ' }
    else
      print 'Ignoring defaults: '
      $ignored_words.map { |e| print e, ', ' }
    end

    if path
      path = File.expand_path(path)
      allObjCFiles = Dir.glob(path + '/**/*.{h,m,swift}') # Recursively search path and subdirectories
    else
      allObjCFiles = Dir.glob('**/*.{h,m,swift}') # Recursively search present directory
    end

    # Store the results of each file's spell check split into errors and warnings
    errors = Array.new
    potentialErrors = Array.new

    # Iterate through each file
    allObjCFiles.each { |path| 
      # Read the file
      input = File.open(path, 'r')
      text = input.read

      # Calculate misspellings and potential misspellings
      #  don't worry about duplicates or empty strings 
      #  as `misspelledWords() takes care of them
      misspellings, probablyRight = self.misspelledWords(text, path)
      errors << misspellings
      potentialErrors << probablyRight
     
      input.close
    }

    puts
    if errors.count > 0
      # Color Errors red, print each error
      puts "\e[1mSpelling Errors:\e[0m"
      errors.each {|error|
        puts error
      }
    else 
      puts "\e[1mNo errors! :D\e[0m"
    end

    if potentialErrors.count > 0
        # Color Warnings yellow, print each warning
        puts "\e[1m\nSpelling Warnings:\e[0m"
        potentialErrors.each {|perror|
          puts perror
      }
    else
      puts "\e[1m\nNo warnings! :D\e[0m"
    end
  end
end

# Go!
if ARGV[0]
  path = ARGV[0]
else
  path = '.'
end
ignoredWordFile = ARGV[1]
CommentSpellCheck.spellCheck(path, ignoredWordFile)
# 