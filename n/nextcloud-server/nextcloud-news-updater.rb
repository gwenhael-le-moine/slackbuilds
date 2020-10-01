#!/usr/bin/env ruby
# frozen_string_literal true
require "json"
require "thwait"                # gem install e2mmap thwait

NC_ROOT = "/srv/www/vhosts/nextcloud-server/htdocs".freeze
NB_THREADS = 2

def occ( command )
  `php -f #{NC_ROOT}/occ #{command}`
end

occ( 'news:updater:before-update' )

users = JSON.parse( occ( 'user:list --output=json' ) )

users.keys.each do |userId|
  feeds = JSON.parse( occ( "news:feed:list #{userId}" ) )

  next if feeds.empty?
  
  slices_size = (feeds.length / NB_THREADS).floor

  ThreadsWait.all_waits( feeds.each_slice( slices_size ).to_a.map do |subfeeds|
                           Thread.new do
                             subfeeds.each do |feed|
                               occ( "news:updater:update-feed #{userId} #{feed['id']}" )
                             end
                           end
                         end )
end

occ( 'news:updater:after-update' )
