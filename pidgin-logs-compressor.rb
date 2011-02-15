def process_dir(path)
  unless File.directory? path
    puts "#{path} is not a directory"
    return
  end

  dir = Dir.new(path)
  dir.entries.each do |filename|
    next if filename == '.' or filename == '..'
    process_user_logs("#{path}#{File::SEPARATOR}#{filename}")
  end
end

def process_user_logs(path)
  return unless File.directory? path

  @files = {}
  logfile_regexp = /([\d]{4}-[\d]{2}-[\d]{2})\..*\.txt/
  dir = Dir.new(path)
  dir.entries.each do |filename|
    next if filename == '.' or filename == '..'
    date_string = logfile_regexp.match(filename)[1]
    datetime = Time.new(date_string)
    @files[datetime] = [] unless @files[datetime]
    @files[datetime] << "#{path}#{File::SEPARATOR}#{filename}"
  end

  join_logs
end

def join_logs
  @files.each_pair do |datetime, filenames|
    next if filenames.size == 1

    new_content = []
    filenames.each do |filename|
      file_content = File.readlines(filename)
      file_content -= [file_content[0]] unless new_content.size == 0
      # tirar ultimo \n
      new_content << file_content
      File.delete(filename)
    end

    open(filenames[0], 'w') { |file|
      file.puts new_content
    }
  end
end

return if ARGV.length == 0
process_dir(ARGV[0])
