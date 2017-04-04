require 'rails/generators/base'

module Feature
  class InstallGenerator < Rails::Generators::Base
     source_root File.expand_path("../templates", __FILE__)

     def install
        copy_file "feature.example.yml", "./config/feature.yml"
        copy_file "feature.initializer.rb", "./config/initializers/feature.rb"
     end
   end
end
