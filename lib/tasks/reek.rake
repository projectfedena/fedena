desc "Will generate Reek output for each Ruby file in RAILS_ROOT."
task(:reek) do
  require 'find'
  require 'fileutils'
  reek_dir_name = "reek"
  reek_dir = "#{RAILS_ROOT}/public/#{reek_dir_name}"
  index_file = "#{reek_dir}/index.html"
  output_files = {}

  unless File.exists?(reek_dir) && File.directory?(reek_dir)
    FileUtils.mkdir(reek_dir)
  end

  Find.find(RAILS_ROOT) do |path|
    if path =~ /\.rb$/i
      output_file = "#{File.basename(path)}.txt"
      cmd = "reek #{path} > #{reek_dir}/#{output_file}"
      puts cmd
      system(cmd)
      output_files[path] = output_file
    end
  end

  puts "Writing index file to #{index_file}..."

  File.open(index_file, 'w') do |file|
    file.write('<html>')
    file.write('<head>')
    file.write('<title>Reek Results</title>')
    file.write('</head>')
    file.write('<body>')
    file.write('<ol>')
    output_files.each do |path, name|
      next unless File.size?(path)
      file.write('<li>')
      file.write('<a href="' + name + '">' + name + '</a>')
      file.write(' (' + path + ')')
      file.write(' file size ' + File.size(path).to_s)
      file.write('</li>')
    end
    file.write('</ol>')
    file.write('</body>')
    file.write('</html>')
  end
end
