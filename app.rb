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
    """
    <html><body>
    <h1>Upload</h1>
    <form action='/files' method='post' enctype='multipart/form-data'>
    <input type='file' name=\"file\" />
    <input type='submit' value='Send'></input>
    </form>
    <!-- TODO: Fix this download form... javascript should update the action based on the md5 value -->
    <h1>Download</h1>
    <form action='/files/xxx' method='get' >
    <input type='text' name='md5'></input>
    <input type='submit' value='Send'></input>
    </form>
    </body></html>
    """
  end

  delete '/files/:md5' do |md5|
    # MAYDO:  Remove any subfolders that are now empty.
    pathname = path(md5)
    FileUtils.rmtree(pathname)
    "ok"
  end
  
  post '/files' do
    tempfile = params['file'][:tempfile]
    filename = params['file'][:filename]
    md5 = Digest::MD5.file(tempfile.path).hexdigest 
    pathname = path(md5)

    FileUtils.mkpath pathname
    if Dir["#{pathname}/*"].empty?
      # store document
      FileUtils.cp(tempfile.path, "#{path(md5)}/#{filename}")
    else
      # rename document
      File.rename(Dir["#{pathname}/*"][0], "#{path(md5)}/#{filename}")
    end
    return md5
  end
  
  def path(md5)
    File.expand_path("../repo/#{md5[0..4]}/#{md5[5..9]}/#{md5}", __FILE__)
  end
end
