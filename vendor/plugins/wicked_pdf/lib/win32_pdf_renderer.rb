require 'win32/open3'
module Win32PdfRenderer

def pdf_from_string(string, options={})
    command_for_stdin_stdout = "#{@exe_path} #{parse_options(options)} -q - - " # -q for no errors on stdout
    p "*"*15 + command_for_stdin_stdout + "*"*15 unless defined?(Rails) and Rails.env != 'development'
    pdf, err = begin
      Open3.popen3(command_for_stdin_stdout,'b') do |stdin, stdout, stderr|
        stdin.write(string)
        stdin.close
        [stdout.read, stderr.read]
      end
    rescue Exception => e
      raise "Failed to execute #{@exe_path}: #{e}"
    end
    raise "PDF could not be generated!\n#{err}" if pdf and pdf.length == 0
    pdf
  end
end