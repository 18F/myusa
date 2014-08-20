# Be sure to restart your server when you modify this file.

MyUSA::Application.config.session_store :cache_store, {
  expire_after: 2.hours
}
