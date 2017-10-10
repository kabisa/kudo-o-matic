require 'rails_helper'
require 'shared/api/v1/shared_expectations'

def expect_record_count_same
  it 'does not change the record count' do
    expect(record_count_before_request).to be == Goal.count
  end
end

def expect_record_count_increase
  it 'increases the record count' do
    expect(record_count_before_request).to be < Goal.count
  end
end

def expect_record_count_decrease
  it 'decreases the record count' do
    expect(record_count_before_request).to be > Goal.count
  end
end

RSpec.describe Api::V1::GoalsController, type: :request do
  include RequestHelpers

  describe 'GET api/v1/goals' do
    let (:request) {'/api/v1/goals'}
    let! (:goal1) {create(:goal)}
    let! (:goal2) {create(:goal)}

    context 'with a valid api-token' do
      let! (:record_count_before_request) {Goal.count}

      let (:user) {create(:user, api_token: 'X0EfAbSlaeQkXm6gFmNtKA')}

      before do
        get request, headers: {'Api-Token': user.api_token}
      end

      expect_record_count_same

      it 'returns all goals' do
        expected =
            {
                data: [
                    {
                        id: goal1.id.to_s,
                        type: 'goals',
                        links: {
                            self: "http://www.example.com#{request}/#{goal1.id}"
                        },
                        attributes: {
                            'created-at': to_api_timestamp_format(goal1.created_at),
                            'updated-at': to_api_timestamp_format(goal1.updated_at),
                            name: goal1.name,
                            amount: goal1.amount,
                            'achieved-on': goal1.achieved_on
                        },
                        relationships: {
                            balance: {
                                links: {
                                    self: "http://www.example.com#{request}/#{goal1.id}/relationships/balance",
                                    related: "http://www.example.com#{request}/#{goal1.id}/balance"
                                }
                            }
                        }
                    },
                    {
                        id: goal2.id.to_s,
                        type: 'goals',
                        links: {
                            self: "http://www.example.com#{request}/#{goal2.id}"
                        },
                        attributes: {
                            'created-at': to_api_timestamp_format(goal2.created_at),
                            'updated-at': to_api_timestamp_format(goal2.updated_at),
                            name: goal2.name,
                            amount: goal2.amount,
                            'achieved-on': goal2.achieved_on
                        },
                        relationships: {
                            balance: {
                                links: {
                                    self: "http://www.example.com#{request}/#{goal2.id}/relationships/balance",
                                    related: "http://www.example.com#{request}/#{goal2.id}/balance"
                                }
                            }
                        }
                    }
                ]
            }.with_indifferent_access

        expect(json).to eq(expected)
      end

      expect_status_200_ok
    end

    context 'with an invalid api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request, headers: {'Api-Token': 'invalid api-token'}
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end

    context 'without an api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end
  end

  describe 'GET api/v1/goals/:id' do
    let (:request) {"/api/v1/goals/#{goal.id}"}
    let! (:goal) {create(:goal)}

    context 'with a valid api-token' do
      let (:user) {create(:user, api_token: 'X0EfAbSlaeQkXm6gFmNtKA')}
      let! (:record_count_before_request) {Goal.count}

      before do
        get request, headers: {'Api-Token': user.api_token}
      end

      expect_record_count_same

      it 'returns the goal associated with the id' do
        expected =
            {
                data: {
                    id: goal.id.to_s,
                    type: 'goals',
                    links: {
                        self: "http://www.example.com#{request}"
                    },
                    attributes: {
                        'created-at': to_api_timestamp_format(goal.created_at),
                        'updated-at': to_api_timestamp_format(goal.updated_at),
                        name: goal.name,
                        amount: goal.amount,
                        'achieved-on': goal.achieved_on
                    },
                    relationships: {
                        balance: {
                            links: {
                                self: "http://www.example.com#{request}/relationships/balance",
                                related: "http://www.example.com#{request}/balance"
                            }
                        }
                    }
                }
            }.with_indifferent_access

        expect(json).to eq(expected)
      end

      expect_status_200_ok
    end

    context 'with an invalid api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request, headers: {'Api-Token': 'invalid api-token'}
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end

    context 'without an api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end
  end

  describe 'POST api/v1/goals' do
    let (:request) {'/api/v1/goals'}
    let! (:goal) {build(:goal)}

    context 'with a valid api-token' do
      let (:user) {create(:user, api_token: 'X0EfAbSlaeQkXm6gFmNtKA')}
      let! (:record_count_before_request) {Goal.count}

      before do
        post request,
             headers: {
                 'Api-Token': user.api_token,
                 'Content-Type': 'application/vnd.api+json'
             },
             params: {
                 data: {
                     type: 'goals',
                     attributes: {
                         name: goal.name,
                         amount: goal.amount,
                         'achieved-on': goal.achieved_on
                     }
                 }
             }.to_json
      end

      it 'persists the created goal' do
        new_goal = Goal.find(assigned_id)

        expect(new_goal.achieved_on).to eq(goal.achieved_on)
        expect(new_goal.name).to eq(goal.name)
        expect(new_goal.amount).to eq(goal.amount)
      end

      expect_record_count_increase

      it 'returns the created goal' do
        expected =
            {
                data: {
                    id: assigned_id,
                    type: 'goals',
                    links: {
                        self: "http://www.example.com#{request}/#{assigned_id}"
                    },
                    attributes: {
                        'created-at': assigned_created_at,
                        'updated-at': assigned_updated_at,
                        name: goal.name,
                        amount: goal.amount,
                        'achieved-on': goal.achieved_on
                    },
                    relationships: {
                        balance: {
                            links: {
                                self: "http://www.example.com#{request}/#{assigned_id}/relationships/balance",
                                related: "http://www.example.com#{request}/#{assigned_id}/balance"
                            }
                        }
                    }
                }
            }.with_indifferent_access

        expect(json).to eq(expected)
      end

      expect_status_201_created
    end

    context 'with an invalid api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        post request,
             headers: {
                 'Api-Token': 'invalid api-token',
                 'Content-Type': 'application/vnd.api+json'
             },
             params: {
                 data: {
                     type: 'goals',
                     attributes: {
                         name: goal.name,
                         amount: goal.amount,
                         'achieved-on': goal.achieved_on
                     }
                 }
             }.to_json
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end

    context 'without an api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        post request,
             headers: {
                 'Api-Token': 'invalid api-token',
                 'Content-Type': 'application/vnd.api+json'
             },
             params: {
                 data: {
                     type: 'goals',
                     attributes: {
                         name: goal.name,
                         amount: goal.amount,
                         'achieved-on': goal.achieved_on
                     }
                 }
             }.to_json
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end
  end

  describe 'PATCH api/v1/goals/:id' do
    let (:request) {"/api/v1/goals/#{goal.id}"}
    let! (:goal) {create(:goal)}
    let(:edited_name) {'edited name'}
    let(:edited_amount) {12345}
    let(:edited_achieved_on) {'2015-01-01'}

    context 'with a valid api-token' do
      let (:user) {create(:user, api_token: 'X0EfAbSlaeQkXm6gFmNtKA')}

      context 'and updated values' do
        let! (:record_count_before_request) {Goal.count}

        before do
          patch request,
                headers: {
                    'Api-Token': user.api_token,
                    'Content-Type': 'application/vnd.api+json'
                },
                params: {
                    data: {
                        type: 'goals',
                        id: goal.id,
                        attributes: {
                            name: edited_name,
                            amount: edited_amount,
                            'achieved-on': edited_achieved_on
                        }
                    }
                }.to_json
        end

        it 'persists the updated goal associated with the id with updated values' do
          updated_goal = Goal.find(goal.id)

          expect(updated_goal.achieved_on.to_s).to eq(edited_achieved_on)
          expect(updated_goal.name).to eq(edited_name)
          expect(updated_goal.amount).to eq(edited_amount)
        end

        expect_record_count_same

        it 'returns the updated goal associated with the id with updated values' do
          expected =
              {
                  data: {
                      id: goal.id.to_s,
                      type: 'goals',
                      links: {
                          self: "http://www.example.com#{request}"
                      },
                      attributes: {
                          'created-at': to_api_timestamp_format(goal.created_at),
                          'updated-at': assigned_updated_at,
                          name: edited_name,
                          amount: edited_amount,
                          'achieved-on': edited_achieved_on
                      },
                      relationships: {
                          balance: {
                              links: {
                                  self: "http://www.example.com#{request}/relationships/balance",
                                  related: "http://www.example.com#{request}/balance"
                              }
                          }
                      }
                  }
              }.with_indifferent_access

          expect(json).to eq(expected)
        end

        expect_status_200_ok
      end

      context 'and without updated values' do
        let! (:record_count_before_request) {Goal.count}

        before do
          patch request,
                headers: {
                    'Api-Token': user.api_token,
                    'Content-Type': 'application/vnd.api+json'
                },
                params: {
                    data: {
                        type: 'goals',
                        id: goal.id
                    }
                }.to_json
        end

        it 'persists the updated goal associated with the id without updated values' do
          updated_goal = Goal.find(goal.id)

          expect(updated_goal.achieved_on).to eq(goal.achieved_on)
          expect(updated_goal.name).to eq(goal.name)
          expect(updated_goal.amount).to eq(goal.amount)
        end

        expect_record_count_same

        it 'returns the updated vote associated with the id without updated values' do
          expected =
              {
                  data: {
                      id: goal.id.to_s,
                      type: 'goals',
                      links: {
                          self: "http://www.example.com#{request}"
                      },
                      attributes: {
                          'created-at': to_api_timestamp_format(goal.created_at),
                          'updated-at': to_api_timestamp_format(goal.updated_at),
                          name: goal.name,
                          amount: goal.amount,
                          'achieved-on': goal.achieved_on
                      },
                      relationships: {
                          balance: {
                              links: {
                                  self: "http://www.example.com#{request}/relationships/balance",
                                  related: "http://www.example.com#{request}/balance"
                              }
                          }
                      }
                  }
              }.with_indifferent_access

          expect(json).to eq(expected)
        end

        expect_status_200_ok
      end
    end

    context 'with an invalid api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        patch request,
              headers: {
                  'Api-Token': 'invalid api-token',
                  'Content-Type': 'application/vnd.api+json'
              },
              params: {
                  data: {
                      type: 'goals',
                      id: goal.id,
                      attributes: {
                          name: edited_name,
                          amount: edited_amount
                      }
                  }
              }.to_json
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end

    context 'without an api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        patch request,
              headers: {
                  'Content-Type': 'application/vnd.api+json'
              },
              params: {
                  data: {
                      type: 'goals',
                      id: goal.id,
                      attributes: {
                          name: edited_name,
                          amount: edited_amount
                      }
                  }
              }.to_json
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end
  end

  describe 'DELETE api/v1/goals/:id' do
    let (:request) {"/api/v1/goals/#{goal.id}"}
    let! (:goal) {create(:goal)}

    context 'with a valid api-token' do
      let (:user) {create(:user, api_token: 'X0EfAbSlaeQkXm6gFmNtKA')}
      let! (:record_count_before_request) {Goal.count}

      before do
        delete request, headers: {'Api-Token': user.api_token}
      end

      it 'deletes the goal associated with the id' do
        expect {Goal.find(goal.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end

      expect_record_count_decrease

      expect_status_204_no_content
    end

    context 'with an invalid api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        delete request, headers: {'Api-Token': 'invalid api-token'}
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end

    context 'without an api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        delete request
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end
  end

  describe 'GET api/v1/goals/next' do
    let (:request) {'/api/v1/goals/next'}
    let! (:balance) {create(:balance, :current)}

    context 'with a valid api-token' do
      let (:user) {create(:user, api_token: 'X0EfAbSlaeQkXm6gFmNtKA')}
      let(:no_next_goal_achieved_on) {nil}
      let(:no_next_goal_name) {'TBD'}
      let(:no_next_goal_amount) {1000}

      context 'and a next goal that is not achieved' do
        let! (:goal) {create(:goal, balance: balance)}
        let! (:record_count_before_request) {Goal.count}

        before do
          get request, headers: {'Api-Token': user.api_token}
        end

        expect_record_count_same

        it 'returns the next goal' do
          expected =
              {
                  data: {
                      id: goal.id.to_s,
                      type: 'goals',
                      attributes: {
                          'created-at': to_api_timestamp_format(goal.created_at),
                          'updated-at': to_api_timestamp_format(goal.updated_at),
                          name: goal.name,
                          amount: goal.amount,
                          'achieved-on': goal.achieved_on
                      }
                  }
              }.with_indifferent_access

          expect(json).to eq(expected)
        end

        expect_status_200_ok
      end

      context 'and a next goal that is achieved' do
        let! (:goal) {create(:goal, :achieved, balance: balance)}
        let! (:record_count_before_request) {Goal.count}

        before do
          get request, headers: {'Api-Token': user.api_token}
        end

        expect_record_count_increase

        it 'creates a new goal that is to be defined' do
          expected =
              {
                  data: {
                      id: assigned_id,
                      type: 'goals',
                      attributes: {
                          'created-at': assigned_created_at,
                          'updated-at': assigned_updated_at,
                          name: no_next_goal_name,
                          amount: goal.amount + no_next_goal_amount,
                          'achieved-on': no_next_goal_achieved_on
                      }
                  }
              }.with_indifferent_access

          expect(json).to eq(expected)
        end

        expect_status_200_ok
      end

      context 'and no next goal' do
        let! (:record_count_before_request) {Goal.count}

        before do
          get request, headers: {'Api-Token': user.api_token}
        end

        expect_record_count_increase

        it 'creates a new goal that is to be defined' do
          expected =
              {
                  data: {
                      id: assigned_id,
                      type: 'goals',
                      attributes: {
                          'created-at': assigned_created_at,
                          'updated-at': assigned_updated_at,
                          name: no_next_goal_name,
                          amount: no_next_goal_amount,
                          'achieved-on': no_next_goal_achieved_on
                      }
                  }
              }.with_indifferent_access

          expect(json).to eq(expected)
        end

        expect_status_200_ok
      end
    end

    context 'with an invalid api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request, headers: {'Api-Token': 'invalid api-token'}
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end

    context 'without an api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end
  end

  describe 'GET api/v1/goals/previous' do
    let (:request) {'/api/v1/goals/previous'}
    let! (:balance) {create(:balance, :current)}

    context 'with a valid api-token' do
      let (:user) {create(:user, api_token: 'X0EfAbSlaeQkXm6gFmNtKA')}

      context 'and a previous goal' do
        let! (:goal1) {create(:goal, :achieved, balance: balance)}
        let! (:goal2) {create(:goal, balance: balance)}
        let! (:record_count_before_request) {Goal.count}

        before do
          get request, headers: {'Api-Token': user.api_token}
        end

        expect_record_count_same

        it 'returns the previous goal' do
          expected =
              {
                  data: {
                      id: goal1.id.to_s,
                      type: 'goals',
                      attributes: {
                          'created-at': to_api_timestamp_format(goal1.created_at),
                          'updated-at': to_api_timestamp_format(goal1.updated_at),
                          name: goal1.name,
                          amount: goal1.amount,
                          'achieved-on': goal1.achieved_on.to_s
                      }
                  }
              }.with_indifferent_access

          expect(json).to eq(expected)
        end

        expect_status_200_ok
      end

      context 'and no previous goal' do
        let! (:record_count_before_request) {Goal.count}
        let(:no_previous_goal_achieved_on) {nil}
        let(:no_previous_goal_name) {'N/A'}
        let(:no_previous_goal_amount) {0}

        before do
          get request, headers: {'Api-Token': user.api_token}
        end

        expect_record_count_same

        it 'returns a not available response' do
          expected =
              {
                  data: {
                      id: nil,
                      type: 'goals',
                      attributes: {
                          'created-at': assigned_created_at,
                          'updated-at': assigned_updated_at,
                          name: no_previous_goal_name,
                          amount: no_previous_goal_amount,
                          'achieved-on': no_previous_goal_achieved_on
                      }
                  }
              }.with_indifferent_access

          expect(json).to eq(expected)
        end

        expect_status_200_ok
      end
    end

    context 'with an invalid api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request, headers: {'Api-Token': 'invalid api-token'}
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end

    context 'without an api-token' do
      let! (:record_count_before_request) {Goal.count}

      before do
        get request
      end

      expect_record_count_same

      expect_unauthorized_response

      expect_status_401_unauthorized
    end
  end
end
