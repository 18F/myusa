require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }
  let(:role) { :foobar }

  describe '#grant_role!' do
    subject { -> { user.grant_role!(role) } }

    context 'role does not exist' do
      it 'creates the role' do
        is_expected.to change(Role, :count).by(1)
      end
      it 'creates an association for user' do
        is_expected.to change(user.roles, :count).by(1)
      end
    end

    context 'role exists' do
      before do
        Role.create(name: role)
      end

      context 'user does not have role' do
        it 'does not create a new role' do
          is_expected.to_not change(Role, :count)
        end

        it 'creates an association for user' do
          is_expected.to change(user.roles, :count).by(1)
        end
      end

      context 'user has role' do
        before do
          user.roles << Role.find_by_name(role)
        end

        it 'does not create a new role' do
          is_expected.to_not change(Role, :count)
        end

        it 'does not create an association for user' do
          is_expected.to_not change(user.roles, :count)
        end
      end
    end
  end

  describe '#has_role?' do
    context 'global role (symbol only)' do
      before { Role.create(name: role) }

      context 'user does not have role' do
        it 'is false' do
          expect(user.has_role?(role)).to be_falsy
        end
      end

      context 'user has role' do
        before { user.roles << Role.find_by_name(role) }

        it 'is true' do
          expect(user.has_role?(role)).to be_truthy
        end
      end
    end

    context 'associated role (role for object)' do
      let(:resource) { FactoryGirl.create(:application) }

      before do
        Role.create(name: role, authorizable: resource)
      end

      context 'user does not have role' do
        it 'is false' do
          expect(user.has_role?(role, resource)).to be_falsy
        end
      end

      context 'user has role on object' do
        before do
          user.roles << Role.where(name: role, authorizable: resource).first
        end

        it 'is true' do
          expect(user.has_role?(role, resource)).to be_truthy
        end
      end
    end
  end
end
