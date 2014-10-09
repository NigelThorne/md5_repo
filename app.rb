require 'fileutils'

class Md5Repo < Sinatra::Base
  reset!
  use Rack::Reloader
  
  get '/files/:md5' do |md5|
    pathname = path(md5)
    files = Dir["#{pathname}/*"]
    filename = files[0]
    puts filename
    if (filename)
#      content_type 'application/octet-stream'
      send_file filename, disposition:"attachment", filename:File.basename(filename), type:'Application/octet-stream'
    else
      status 404
      return "oops"
    end
  end
  
  get '/' do
    return """
    <html><body><form action=\"/files\" method=\"post\" enctype=\"multipart/form-data\">
    <input type='file' name=\"file\"></input><input type='submit' value=\"Send\"></input></form></body>
    </html>
    """
  end
  
  post '/files' do
    tempfile = params['file'][:tempfile]
    filename = params['file'][:filename]
    md5 = Digest::MD5.file(tempfile.path).hexdigest 
    FileUtils.mkpath path(md5)
    if Dir["#{pathname}/*"].empty?
      FileUtils.cp(tempfile.path, "#{path(md5)}/#{filename}")
    end
    return md5
  end
  
  def path(md5)
    File.expand_path("../repo/#{md5[0..4]}/#{md5[5..9]}/#{md5}", __FILE__)
  end
end
