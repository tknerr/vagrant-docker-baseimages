
require 'mixlib/shellout'

# reopen String class to add #unindent for heredocs
# see http://stackoverflow.com/a/3772911/2388971
class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end
