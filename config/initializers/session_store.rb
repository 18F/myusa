# Be sure to restart your server when you modify this file.

MyUSA::Application.config.session_store :cookie_store, {
  key: '_myusa_session',
  expire_after: 2.hours
}
