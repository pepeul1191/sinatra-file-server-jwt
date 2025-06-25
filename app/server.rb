require 'sinatra/base'

class ApplicationController < Sinatra::Base
  get '/' do
    'hol'
  end
end