#encoding: UTF-8
#!/usr/bin/env ruby
require 'optparse'
require 'tempfile'
require 'fileutils'
require 'rubygems'

class HasselRaw

  def initialize
    @options = { list: false, string: "" }
    @parser ||= OptionParser.new do |opts|
      opts.banner = "Replace Hasselblad occurrence by random or specified string"
      opts.separator ""
      opts.separator "Usage: HasselRaw [options] dng_file [DNG_FILE ...]"
      opts.separator ""
      opts.separator "options:"

      opts.on("-n", "--name STRING", "Specify replacement string") do |string|
        @options[:string] = string[0..7].ljust(8)
      end
      opts.on("-l", "--list", "List Hasselblad occurence on files") { |list| @options[:list] = true}
    end
  end

  def david!(files)
    @parser.parse!

    dng_files = file_list(files)
    p "Nothing to do" and return if dng_files.empty?

    if @options[:list]
      dng_files.each do |file|
        File.open(file, mode: 'rb') do |f|
          puts "File : #{file}"
          f.each_line do |line|
            puts "-> #{line}" if line =~ /Hasselblad/
          end
          puts ""
        end
      end
    else
      dng_files.each do |file_name|
        p "Processing : #{file_name}"

        begin
          temp_file = Tempfile.new('raw_tmp')

          File.open(file_name, 'rb') do |file|
            file.each_line do |line|
              temp_file.puts line.gsub(/Hasselblad/, replacement_string)
            end
          end
          temp_file.close
          FileUtils.mv(temp_file.path, file_name)
        ensure
          temp_file.close
          temp_file.unlink
        end

      end
    end
  end

  def file_list(files)
    files.empty? ? Dir["./*.dng"] : files
  end

  def replacement_string
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    @options[:string].empty? ? (0...10).map { o[rand(o.length)] }.join : @options[:string]
  end

end

HasselRaw.new.david!(ARGV)
