require 'fileutils'

require 'sinatra/cross_origin'

#todo: https://github.com/britg/sinatra-cross_origin

class Md5Repo < Sinatra::Base
  reset!
  use Rack::Reloader

  
  before do
     content_type  = 'text/plain'
     headers  'Access-Control-Allow-Origin' => '*', 
              'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
              'Access-Control-Allow-Headers' => 'Content-Type'              
  end

  set :protection, false
  
  
#  enable :cross_origin
  
#  set :allow_origin, :any
#  set :allow_methods, [:get, :post, :options]
#  set :allow_credentials, true
#  set :max_age, "1728000"
#  set :expose_headers, ['Content-Type']
  
  get '/files/:md5' do |md5|
    pathname = path(md5)
    files = Dir["#{pathname}/*"]
    filename = files[0]
    puts filename
    if (filename)
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
    <input type='file' name='file' />
    <input type='submit' value='Send'></input>
    </form>
    <h1>Upload</h1>
    <form action='/files' method='post' enctype='multipart/form-data'>
    <input type='text' name='filename' /><br/>
    
    <textarea name='body' rows='20' cols='80'></textarea>
    <input type='submit' value='Send'></input>
    </form>
    <!-- TODO: Fix this download form... javascript should update the action based on the md5 value -->
    <h1>Download</h1>
    <form action='#' method='get' >
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
    if params['file']
      tempfile = params['file'][:tempfile]
      filename = params['file'][:filename]
      return store(tempfile.path, filename)
    end

    filename = params['filename']
    if filename.empty? 
      status 400
      return "oops - no filename"
    end

    content = params['body']
    tempfile = Tempfile.new filename #MAYDO : bit wasteful to write to file twice...
    tempfile.write content
    tempfile.close
    return store(tempfile.path, filename)		

  end
  
  def path(md5)
    File.expand_path("../repo/#{md5[0..4]}/#{md5[5..9]}/#{md5}", __FILE__)
  end

	# save file
  # or rename file is file exists and names don't match
  def store(tempfile,filename)
		md5 = Digest::MD5.file(tempfile).hexdigest 
		pathname = path(md5)

		FileUtils.mkpath pathname
		if Dir["#{pathname}/*"].empty?
		  # store document
		  FileUtils.cp(tempfile, "#{path(md5)}/#{filename}")
		else
		  # rename document
		  File.rename(Dir["#{pathname}/*"][0], "#{path(md5)}/#{filename}")
		end
		md5
	end
  
end
