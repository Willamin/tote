require "./tote/*"
require "option_parser"

OptionParser.parse! do |parser|
  parser.banner = "Usage: tote [arguments] [file]"
  parser.on("-v", "--version", "Show the version number") {
    puts Tote::VERSION
  }
  parser.on("-h", "--help", "Show this help message") { puts  parser }
end

module Tote
end
