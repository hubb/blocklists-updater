#!/usr/bin/env ruby

require 'open-uri'
require 'progressbar'

# Path to Transmission blocklists folder
BLOCKLISTS_PATH = "/Users/hubb/Library/Application Support/Transmission/blocklists"
BLOCKLISTS_PATH = Dir.home + "/Library/Application Support/Transmission/blocklists"

# Blocklists we want to keep updated with thei uris
blocklists = {
  "level1"          => "http://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz",
  "level2"          => "http://list.iblocklist.com/?list=bt_level2&fileformat=p2p&archiveformat=gz",
  "level3"          => "http://list.iblocklist.com/?list=bt_level3&fileformat=p2p&archiveformat=gz",
  "Microsoft"       => "http://list.iblocklist.com/?list=bt_microsoft&fileformat=p2p&archiveformat=gz",
  "Primary threats" => "http://list.iblocklist.com/?list=ijfqtofzixtwayqovmxn&fileformat=p2p&archiveformat=gz"
}

def update_list name, uri
  path_to_file = BLOCKLISTS_PATH + "/blocklist-#{name}.gz"
  progress = nil
  blocklist_gz = open(path_to_file, "wb")

  blocklist_gz.write(open(uri,
    :read_timeout => 5,
    :content_length_proc => lambda {|t|
      if t && 0 < t
        progress = ProgressBar.new(name, t)
        progress.file_transfer_mode
      end
    },
    :progress_proc => lambda {|s|
      progress.set s if progress
    }).read)
  blocklist_gz.close

  unzip(blocklist_gz, name)
  File.delete(blocklist_gz)
end

def unzip gz_file, name
  Zlib::GzipReader.open(gz_file) do |gz|
    blocklist_file = BLOCKLISTS_PATH + "/blocklist-#{name}.bin"
    File.open(blocklist_file, "w") do |g|
      IO.copy_stream(gz, g)
    end
  end
end

puts "Updating #{blocklists.count} blocklists.. \n\n"

blocklists.each do |name, uri|
  update_list(name, uri)
  sleep 1.5
end

puts "\n\nIt's all done!"