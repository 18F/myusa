
require 'feature_helper'

def auth_for_user(opts = {})
  visit(url_for({
    controller: 'oauth',
    action: 'authorize',
    response_type: 'code',
    client_id: app1_client_id,
    redirect_uri: redirect_uri,
    only_path: true
  }.merge(opts)))
end

describe 'OauthApps' do
  let(:user) { create_confirmed_user_with_profile(email: 'first@user.org') }
  let(:owner_user) { create_confirmed_user_with_profile(email: 'owner@user.org') }
  let(:redirect_uri) { 'http://localhost/' }
  let(:app1_scopes) do
    ['profile',
     'notifications',
     'tasks',
     'profile.email',
     'profile.middle_name']
  end
  let(:app1_client_id) { app1.oauth2_client.client_id }
  let(:is_public) { true }
  let(:app1_url) { 'http://app1host.com' }
  let(:app1) do
    a = App.create(
      name: 'App1',
      user_id: owner_user.id,
      custom_text: 'Custom text for test',
      redirect_uri: redirect_uri,
      url:          app1_url,
      is_public: is_public
    )
    a.oauth_scopes = OauthScope.where(scope_name: app1_scopes)
    a
  end

  context 'with a non-public sandboxed app' do
    let(:is_public) { false }
    context 'when logged in with a user who owns a sandboxed app' do
      before { login(owner_user) }

      describe 'Authorize sandbox application by owner' do
        it "asks for authorization and redirect after clicking 'Allow'" do
          auth_for_user
          click_button('Allow')

          # NOTE: if we use a browser here, current_url resolves before the redirect
          # fires, so none of this url string parsing works.
          uri = URI.parse(current_url)
          params = CGI.parse(uri.query)
          code = (params['code'] || []).first

          expect(code).to_not be_empty
        end

        it 'should log the sandbox application authorization activity, associated with the user' do
          pending 'app activity logs not added'
          auth_for_user
          expect(page).to have_content('The App1 application wants to:')
          click_button('Allow')
          expect(user.app_activity_logs.count).to_eq 1
          expect(user.app_activity_logs.first.app).to_eq app1
        end
      end
    end

    context 'when logged in with a user who does not own the sandboxed app' do
      before do
        login(user)
      end

      describe 'Does not allow sandbox application installation by non owner' do
        it 'code in params should not have a value' do
          auth_for_user
          expect(page).to have_content("You are accessing an application that doesn't exist or hasn't given you sufficient access.")
        end
      end
    end

    context 'when NON logged in with a user who does not own the sandboxed app' do
      describe 'Does not allow sandbox application installation by non owner' do
        it 'presents the login page' do
          auth_for_user
          expect(page).to have_content('You need to sign in or sign up before continuing.')
        end
      end
    end
  end

  describe 'Authorize application' do
    context 'when the app is known' do
      it 'redirects to a login page to authorize a new app' do
        auth_for_user
        expect(current_path).to eql new_user_session_path
        expect(page).to have_content('Sign In with Google')
        expect(page).to have_link('Return to App1', href: app1_url)
      end
    end

    context 'when the app is not known' do
      it 'redirects to a friendly error page if the app is unknown' do
        auth_for_user client_id: 'xyz'
        expect(page).to have_content("We're Sorry")
        expect(page).to have_content("You are accessing an application that doesn't exist or hasn't given you sufficient access.")
      end
    end
  end

  context 'when logged in' do
    before { login(user) }

    describe 'Authorize application' do
      it 'should log the application authorization activity, associated with ' \
          'the user' do
        pending 'app activity logs not added'
        auth_for_user
        expect(page).to have_content('The App1 application wants to:')
        expect(page).to have_link('Return to App1', href: app1_url)
        click_button('Allow')
        expect(user.app_activity_logs.count).to_eq 1
        expect(user.app_activity_logs.first.app).to_eq App.find_by_name('App1')
      end
    end

    describe 'Authorize application with scopes' do
      context 'When redirect URI has parameters' do
        let(:redirect_uri) { 'http://apphost.com?something=true' }

        it 'should maintain those parameters when redirecting with ' \
            'unauthorized scopes error' do
          auth_for_user scope: 'profile.email profile.address', redirect_uri: 'http://apphost.com/'
          expect(current_url).to include(redirect_uri.split('?').second)
          expect(current_url).to include('error=access_denied')
        end
      end

      it 'does not allow requests that contain unauthorized scopes' do
        auth_for_user scope: 'profile.email profile.address'
        expect(CGI.unescape(current_url)).to have_content(
          "#{redirect_uri}?error=access_denied&error_description=" \
          "#{I18n.t('unauthorized_scope')}")
      end

      it "asks for authorization and redirect after clicking 'Allow'" do
        auth_for_user scope: 'profile notifications profile.email'
        expect(page).to have_content('The App1 application wants to:')
        expect(page).to have_content('Read your profile information')
        expect(page).to have_content('Send you notifications')
        expect(page).to have_content('Read your email address')
        expect(page).to_not have_content('Read your address')
        expect(page).to have_link('Return to App1', href: app1_url)
        expect(page).to have_checked_field('selected_scopes_profile')
        user.reload
        expect(user.oauth2_authorization_for(app1.oauth2_client)).to be_nil
        click_button('Allow')
        user.reload
        expect(user.oauth2_authorization_for(app1.oauth2_client).scope).to match(/email/)
        expect(page.current_url.split('?').first).to eq redirect_uri
      end

      it 'does not add an authorization when user clicks cancel' do
        auth_for_user scope: 'profile notifications'
        user.reload
        expect(user.oauth2_authorization_for(app1.oauth2_client)).to be_nil
        click_button('Cancel')
        user.reload
        expect(user.oauth2_authorization_for(app1.oauth2_client)).to be_nil
        expect(page.current_url.split('?').first).to eq redirect_uri
      end

      it 'does not display authorization screen after authorizing' do
        auth_for_user scope: 'profile notifications profile.email'
        click_button('Allow')
        auth_for_user scope: 'profile notifications profile.email'
        expect(page).to_not have_content('The App1 application wants to:')
        expect(page.current_url.split('?').first).to eq redirect_uri
      end
    end
  end

  def auth_scopes(app, u)
    a = u.oauth2_authorization_for(app)
    a.try(:scopes).try(:to_a) || []
  end

  describe 'user selected scopes' do
    before do
      login(user)
      expect(auth_scopes(app1, user)).to be_blank
    end

    context 'user has profile data' do
      before do
        expect(user.first_name).to be_present
        expect(user.email).to be_present
        auth_for_user scope: app1_scopes.join(' ')
      end

      it 'user scopes match requested scopes' do
        click_button('Allow')
        user.reload
        expect(auth_scopes(app1, user).sort).to eq app1_scopes.sort
      end

      it 'user scopes only contain checked scopes' do
        uncheck('selected_scopes_profile.email')
        click_button('Allow')
        user.reload
        app_scopes = app1_scopes - ['profile.email']
        expect(auth_scopes(app1, user).sort).to eq app_scopes.sort
      end
    end

    context 'user has incomplete user data' do
      before do
        expect(user.profile.middle_name).to be_blank
        auth_for_user scope: app1_scopes.join(' ')
      end

      it 'input box is presented for incomplete fields' do
        expect(page).to have_field('new_profile_values_profile.middle_name')
      end

      it 'checkbox is presented for complete fields' do
        expect(page).to have_field('selected_scopes_profile.email')
      end

      it 'data from input box is persisted' do
        fill_in 'new_profile_values_profile.middle_name', with: 'Example'
        click_button('Allow')
        user.reload
        expect(user.profile.middle_name).to eq 'Example'
      end
    end
  end
end
