#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w[helper])

require 'steps/login_steps'

run_story :type => RailsStory do |runner|
  runner.steps << LoginSteps.new
  runner.load File.expand_path(__FILE__).gsub(".rb","")
end

