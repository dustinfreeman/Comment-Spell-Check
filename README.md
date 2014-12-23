# About

Comment Spell Check is a Ruby script to recursively scan a directory and spell check every .h, .m and .swift file found therein.

## Special Thanks To

+ [GNU Aspell](http://aspell.net/)
+ [Evan Weaver for the Raspell Gem](http://blog.evanweaver.com/2007/03/10/add-gud-spelning-to-ur-railz-app-or-wharever/)
+ [Raspell Gem Source](https://github.com/evan/raspell)
+ [ANSI escape sequences](http://ascii-table.com/ansi-escape-sequences.php)

# Install

You need to have installed the `raspell` gem (listed in Gemfile) and also to have executable 'aspell'. 

		brew install aspell
		bundle install

# Use

Run `ruby csc.rb $PATH_TO_DIRECTORY_OF_HEADER_FILES` and get Terminal output of errors and warnings. You can add a second parameter path to a file which contains newline separated words to ignore spell checking. Without a parameter the current directory is used along with a short default list of ignorable words.

Errors are strings Aspell thinks are misspelled. For example with the dictionaries I have installed Aspell thinks 'resizing' is incorrect. Errors are shown in red.

Warnings are what Aspell thinks are wrong but Comment Spell Check knows may not be wrong. For example anything starting with camel case capitalization is put in the warnings list instead of errors. Warnings are shown in yellow.

Suggestions are listed after each error/warning: “Did you mean…?”

# Issues

- Does not work with `#` comments.
- Hard-coded on .h, .m and .swift file extensions.
- Auto runs in current directory: prevents importing into other Ruby code bases.

# License

[MIT License](http://www.opensource.org/licenses/MIT) included in LICENSE file.
