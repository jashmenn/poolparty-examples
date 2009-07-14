=begin rdoc
== Overview
== Requirements
== Bugs
== References
=end

module PoolParty
  module Plugin
    class Hadoop < Plugin
      def cascading(o={}, &block)
        do_once do
        end

        def install
          "cd /usr/local/src && git clone git://github.com/cwensel/cascading.git"
          "cd /usr/local/src/cascading"
          "git checkout #{revision}"
          "remove the jetty-ext stuff in build.xml"
          "ant -Dhadoop.home=/usr/local/hadoop compile"
          "ant -Dhadoop.home=/usr/local/hadoop jar"
        end

        def revision
          "b0d1970a86303b39126f29"
        end
      end
    end
  end
end

 
