require 'spec_helper.rb'

describe 'Routes to API' do
  let(:json) { { format: :json } }

  context 'URLs without a version segment' do
    describe 'route to v1 controllers' do
      it 'with a GET to a controller' do
        expect(get: '/api/profile').to route_to('api/v1/profiles#show', json)
      end
      it 'with a GET to a controller with an ID' do
        expect(get: '/api/tasks/12').to route_to('api/v1/tasks#show',
                                                 id: '12', format: :json)
      end
      it 'with a POST to a controller' do
        expect(post: '/api/tasks').to route_to('api/v1/tasks#create', json)
      end
    end
  end
end
