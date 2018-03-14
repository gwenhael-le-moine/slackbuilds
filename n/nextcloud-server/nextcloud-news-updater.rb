#!/usr/bin/env ruby
require "json"
require "thwait"

NC_ROOT="/srv/www/vhosts/nextcloud-server/htdocs"

def occ( command )
  `php -f #{NC_ROOT}/occ #{command}`
end

occ( 'news:updater:before-update' )

ThreadsWait.all_waits( JSON.parse( occ( 'news:updater:all-feeds' ) )["feeds"]
  .map do |feed|
  Thread.new do
    occ( "news:updater:update-feed #{feed['id']} #{feed['userId']}" )
  end
end )

occ( 'news:updater:after-update' )
