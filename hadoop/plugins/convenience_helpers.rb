=begin rdoc
=end

module PoolParty
  module Plugin
    class ConvenienceHelpers < Plugin
      def before_load(o={}, &block)
        add_packages
        add_aliases
      end

      def add_packages
        has_package "tree"
        has_package "vim-nox"
        has_package" screen"
        has_package" irb"
      end

      def add_aliases
        has_bash_alias :name => "inspect-poolparty-recipes", :value => "vi /var/poolparty/dr_configure/chef/cookbooks/poolparty/recipes/default.rb"
        has_bash_alias :name => "cd-cookbooks", :value => "pushd /var/poolparty/dr_configure/chef/cookbooks/poolparty"
      end
    end
  end
end


