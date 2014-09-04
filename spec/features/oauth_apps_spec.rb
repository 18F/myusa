
require 'feature_helper'

def auth_for_user(opts = {})
  visit(oauth_authorization_path({
    response_type: 'code',
    client_id: app1.uid,
    redirect_uri: redirect_uri,
    only_path: true
  }.merge(opts)))
end

describe 'OAuth' do
  let(:user) { create_confirmed_user_with_profile(email: 'first@user.org') }
  let(:owner_user) do
    create_confirmed_user_with_profile(email: 'owner@user.org')
  end
  let(:redirect_uri) { 'http://example.gov/' }
  let(:app1_scopes) do
    ['profile',
     'notifications',
     'tasks',
     'profile.email',
     'profile.middle_name']
  end
  let(:is_public) { true }
  let(:app1) do
    Doorkeeper::Application.create(
      name: 'App1',
      owner: owner_user,
      redirect_uri: redirect_uri,
      url:          'http://app1host.com'
    )
  end

  # Sandboxing is not implemented with Doorkeeper yet
  pending 'with a non-public sandboxed app' do

    let(:is_public) { false }
    context 'when logged in with a user who owns a sandboxed app' do
      before { login(owner_user) }

      describe 'Authorize sandbox application by owner' do
        it "asks for authorization and redirect after clicking 'Allow'" do
          auth_for_user
          click_button('Allow')

          # NOTE: if we use a browser here, current_url resolves before the
          # redirect fires, so none of this url string parsing works.
          uri = URI.parse(current_url)
          params = CGI.parse(uri.query)
          code = (params['code'] || []).first

          expect(code).to_not be_empty
        end

        it 'should log the sandbox application authorization activity, ' \
           'associated with the user' do
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
          expect(page).to have_content(
            "You are accessing an application that doesn't exist or hasn't " \
            'given you sufficient access.')
        end
      end
    end

    context 'when NON logged in with a user who does not own the sandboxed ' \
            'app' do
      describe 'Does not allow sandbox application installation by non owner' do
        it 'presents the login page' do
          auth_for_user
          expect(page).to have_content(
            'You need to sign in or sign up before continuing.')
        end
      end
    end
  end

  describe 'Authorize application' do
    context 'when the app is known' do
      it 'redirects to a login page to authorize a new app' do
        auth_for_user
        expect(current_path).to eql new_user_session_path
        expect(page).to have_content('Connect with Google')
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
        click_button('Allow')
        expect(user.app_activity_logs.count).to_eq 1
        expect(user.app_activity_logs.first.app).to_eq App.find_by_name('App1')
      end

      context 'when the app is not known' do
        it 'redirects to a friendly error page if the app is unknown' do
          auth_for_user client_id: 'xyz'
          expect(page).to have_content('An error has occurred')
          expect(page).to have_content(
            'Client authentication failed due to unknown client')
        end
      end
    end
  end

  pending 'updating profile data' do
    before do
      login(user)
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
