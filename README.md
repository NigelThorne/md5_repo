md5_repo
========

Service to Store/Retrieve files by their md5 (with their original filename)

Known Limitations: 
* You can't rename files - so if you get a file by key, it will have the first name we saw for it.
* No security. Don't run this on an open server.


build with 
> docker build --tag="nwt/mr_blobby:latest" .
run with 
> mkdir repo
> docker run -d --name mr_blobby_2 -v repo:/usr/src/repo -P nwt/mr_blobby:latest