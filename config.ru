# require 'rubygems'
require 'bundler/setup'
require 'faye'
require './trashmail'

use Faye::RackAdapter, :mount      => '/faye',
                       :timeout    => 45

run Sinatra::Application
