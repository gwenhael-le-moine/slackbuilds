#!/usr/bin/env ruby
require "json"
require "thwait"

NC_ROOT = "/srv/www/vhosts/nextcloud-server/htdocs".freeze
NB_THREADS = 2

def occ( command )
  `php -f #{NC_ROOT}/occ #{command}`
end

occ( 'news:updater:before-update' )

feeds = JSON.parse( occ( 'news:updater:all-feeds' ) )["feeds"]

slices_size = (feeds.length / NB_THREADS).floor

ThreadsWait.all_waits( feeds.each_slice( slices_size ).to_a.map do |subfeeds|
                         Thread.new do
                           subfeeds.each do |feed|
                             occ( "news:updater:update-feed #{feed['id']} #{feed['userId']}" )
                           end
                         end
                       end )

occ( 'news:updater:after-update' )
