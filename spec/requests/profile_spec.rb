require 'spec_helper'

describe "API Requests" do
  
  shared_api_methods
  
  describe "Group Profile" do
    describe "GET /api/v1/profiles" do
      context "when the request has a valid token" do
        context "when the app does not have permission to read the user's profile" do
          before do
            @app.oauth_scopes.destroy_all
            @token = build_access_token(@app)
          end

          it "should return an error and message" do
            response = get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.status).to eq 403
            parsed_json = JSON.parse(response.body)
            expect(parsed_json["message"]).to eq "You do not have permission to read that user's profile."
          end
        end

        context "when app has limited scope" do
          before do
            @limited_scope_app = App.create(:name => 'app_limited', :redirect_uri => "http://localhost/")
            @limited_scope_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
            # Adding just one profile sub scope to test that only this one is presnt in json.
            @limited_scope_app.oauth_scopes << OauthScope.find_by_scope_name("profile.first_name")
            @token = build_access_token(@limited_scope_app)
          end

          it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
            response = get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json["first_name"]).to eq 'Joe'
            expect(parsed_json["id"]).to_not be_nil
            expect(parsed_json["uid"]).to_not be_nil
            expect(parsed_json["email"]).to be_nil  # profile.first_name is the only profile subscope app is authorized to access.
            # ...
            expect(parsed_json["is_veteran"]).to be_nil  # profile.first_name is the only profile subscope app is authorized to access.
            expect(parsed_json["is_retired"]).to be_nil  # profile.first_name is the only profile subscope app is authorized to access.
          end
        end

        context "when app has all scopes" do
          before do
            @all_scopes_app = App.create(:name => 'app_all_scopes', :redirect_uri => "http://localhost/")
            @all_scopes_app.oauth_scopes = OauthScope.top_level_scopes.where(:scope_type => 'user')
            # Adding just one profile sub scope to test that only this one is presnt in json.
            @all_scopes_app.oauth_scopes.concat OauthScope.where("scope_name like ?", 'profile.%').all
            @token = build_access_token(@all_scopes_app)
          end

          it "should return JSON with only app requested user profile attritues in addition to an id and a unique identifier" do
            response = get "/api/profile", nil, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
            expect(response.status).to eq 200
            parsed_json = JSON.parse(response.body)
            expect(parsed_json).to_not be_nil
            expect(parsed_json["first_name"]).to eq 'Joe'
            expect(parsed_json["id"]).to_not be_nil
            expect(parsed_json["uid"]).to_not be_nil
            expect(parsed_json["email"]).to_not be_nil
            # ...
            expect(parsed_json["is_veteran"]).to be_nil # we did not specify a value for this
            expect(parsed_json["is_retired"]).to eq "0"
          end
        end

        context "when the user queried exists" do
          before do
            @token = build_access_token(@app)
          end

          context "when the schema parameter is set" do
            it "should render the response in a Schema.org hash" do
              response = get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer #{@token}"}
              expect(response.status).to eq 200
              parsed_json = JSON.parse(response.body)
              expect(parsed_json).to_not be_nil
              expect(parsed_json["email"]).to eq 'joe@citizen.org'
            end
          end
        end
      end

      context "when the request does not have a valid token" do
        it "should return an error message" do
          response = get "/api/profile", {"schema" => "true"}, {'HTTP_AUTHORIZATION' => "Bearer bad_token"}
          expect(response.status).to eq 401
          parsed_json = JSON.parse(response.body)
          expect(parsed_json["message"]).to eq "Invalid token"
        end
      end
    end
  end

end
