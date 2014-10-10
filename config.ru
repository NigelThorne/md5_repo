# config.ru
#require 'bundler/setup'
#Bundler.require(:default)

require 'rubygems'
require 'sinatra/base'
require 'rack/reloader'
require './app'

run Md5Repo
