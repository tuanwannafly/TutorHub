# frozen_string_literal: true

# SimpleForm initializer — generated for TutorHub.
#
# SimpleForm is loaded lazily by Bundler via `gem "simple_form"` in the Gemfile.
# This initializer sets sensible defaults that play nicely with our hand-written
# CSS. Per-field overrides happen in the views with `input_html:` /
# `wrapper_html:` options.

SimpleForm.setup do |config|
  # Wrappers — defaults match our CSS classes (.input / .field).
  config.wrappers :default, class: "field" do |f|
    f.use :html5
    f.use :placeholder
    f.use :label, class: "form-label"
    f.use :input, class: "input"
    f.use :full_error, wrap_with: { tag: "span", class: "error" }
    f.use :hint,       wrap_with: { tag: "span", class: "hint" }
  end

  # Vertical form (label above input).
  config.default_wrapper = :default

  # Components
  config.boolean_style = :nested
  config.button_class = "btn btn-primary"
  config.error_notification_class = "form-errors__title"
  config.error_notification_tag = :p
  config.label_text = ->(label, _required, _attribute) { label.to_s }

  # Browser hints
  config.browser_validations = true

  # Translation namespace
  config.i18n_scope = "simple_form"
end