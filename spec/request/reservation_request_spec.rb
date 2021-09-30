require 'rails_helper'

RSpec.describe '/api/v1/so_reservations', :type => :request do
  describe 'POST /api/v1/so_reservations' do
    subject(:request_call) do
        post '/api/v1/so_reservations', params: {
            reservation: {
              start_time: DateTime.now,
              customer_id: customer.id,
              table_id: table.id,
              number_of_people: number_of_people
              }
        }
    end

    let(:customer) { create(:customer) }
    let(:table) { create(:table, seats: 2) }

    context 'when reservation params are valid' do
      let(:reservation_date) { 10.days.from_now }
      let(:number_of_people) { table.seats - 1 }
      
      before do
          request_call
      end

      it 'returns code 200' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the reservation date is invalid' do
      let(:reservation_date) { DateTime.now }
      let(:number_of_people) { table.seats - 1}

      before do
        request_call
      end

      it 'returns code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns error message informing about the issue' do
        expect(response.body).to eq("{\"error\":\"Incorrect reservation date - it has to be at least 7 days from now.\"}") 
      end
    end

    context 'when the number of people is greater than seats at the table' do
        let(:reservation_date) { 10.days.from_now }
        let(:number_of_people) { table.seats + 1 }
  
        before do
          request_call
        end
  
        it 'returns code 422' do
          expect(response).to have_http_status(422)
        end
  
        it 'returns error message informing about the issue' do
          expect(response.body).to eq("{\"error\":\"Incorrect table selected - not enough seats.\"}") 
        end
      end
  end
end
