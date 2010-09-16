require 'debian/build'

include Debian::Build
require 'debian/build/config'

namespace "package" do
  Package.new(:"libalsa-ruby") do |t|
    t.version = '0.1'
    t.debian_increment = 1

    t.source_provider = GitExportProvider.new
  end
end

require 'debian/build/tasks'
