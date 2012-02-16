# About

Comment Spell Check is a Ruby script to recursively scan a directory and spell check every Objective-C header file found therein.

## Special Thanks To

+ [GNU Aspell](http://aspell.net/)
+ [Evan Weaver for the Raspell Gem](http://blog.evanweaver.com/2007/03/10/add-gud-spelning-to-ur-railz-app-or-wharever/)
+ [Raspell Gem Source](https://github.com/evan/raspell)
+ [ANSI escape sequences](http://ascii-table.com/ansi-escape-sequences.php)

# Install

You need to have installed the 'raspell' gem and also to have installed 'aspell'. 

		brew install aspell
		gem install raspell

# Use

Run `ruby csc.rb $PATH_TO_DIRECTORY_OF_HEADER_FILES` and get Terminal output of errors and warnings. 

Errors are strings Aspell thinks are misspelled. For example with the dictionaries I have installed Aspell thinks 'resizing' is incorrect. Errors are shown in red.

Warnings are what Aspell thinks are wrong but Comment Spell Check knows probably are not wrong. For example anything starting with camel case capitalization is put in the warnings list instead of errors. Warnings are shown in yellow.

# What's Next

Clearer results, more power, and more options:

1. Parameter to ignore words (stdin or file path flag?)
2. Suggestions of how X should be spelled

# License

[MIT License](http://www.opensource.org/licenses/MIT) included in LICENSE file.