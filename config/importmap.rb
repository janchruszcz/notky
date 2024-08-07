# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: '@hotwired--stimulus.js' # @3.2.2
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'sortablejs' # @1.15.2
pin 'stimulus-sortable' # @4.1.1
pin '@rails/request.js', to: '@rails--request.js.js' # @0.0.8
pin 'el-transition' # @0.0.7
pin 'flatpickr' # @4.6.13
pin 'stimulus-flatpickr' # @3.0.0
