# Pin npm packages by running ./bin/importmap
#
# Pinning a JavaScript module tells importmap-rails that we'd like to use the
# specified version of the module as the default when a browser would otherwise
# have to choose between multiple versions of the module.
#
# After adding a new pin, you'll need to run `./bin/importmap bin/rails turbo:install stimulus-install`
# (or just `./bin/importmap`) to update the JavaScript bundle manifest.
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"