module Feature
  class InstallGenerator < Rails::Generators::Base
     def install
        touch "/config/feature.yml"
     end
   end
end