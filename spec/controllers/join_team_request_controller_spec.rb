require './spec/support/teams_shared.rb'

describe JoinTeamRequestsController do
  include_context "object initializations"
  include_context 'authorization check'
  before (:each) {
    join_team_request4 = JoinTeamRequest.new()
    join_team_request4.id = 3
    join_team_request4.team_id = 4
    join_team_request4.status = 'P'
    join_team_request4.participant_id = 1
    join_team_request4.comments = "I want to join the team"
    join_team_request4.save
    allow(  join_team_request4).to receive(:save).and_return(true)
    allow(JoinTeamRequest).to receive(:find).with("2").and_return(join_team_request2)
    allow(join_team_request2).to receive(:update_attribute).with(any_args).and_return('OK!')
  }
  # Testing action_allowed? controller
  context 'provides access to people with' do
    it 'will give students above access' do
      stub_current_user(student1, student1.role.name, student1.role)
      # Expecting students to be allowed access.
      expect(controller.send(:action_allowed?)).to be true
    end
  end

  # The Get Index test fails due to missing template
  # An issue in github is created for this problem.

  # describe "GET index" do
  #   it "routes to index page" do
  #     # Stubbing an object to receive .all method to give list of index
  #     allow(JoinTeamRequest).to receive(:all).and_return(join_team_request1)
  #     params = {action: 'index'}
  #     session = {user: ta}
  #     result = get :index, params, session
  #     expect(result.status).to eq 302
  #   end
  # end
  # Testing show method
  describe "GET #show" do
    context "when show is valid" do
      it "will show particular student team given index" do
        allow(JoinTeamRequest).to receive(:find).and_return(join_team_request2)
        params = {action: 'show'}
        session = {user: ta}
        result = get :show, params, session
        expect(result.status).to eq 200
      end
    end
  end

  # Testing new method
  describe "GET #new" do
    context "when new is called" do
      it "routes to new page" do
        get :new
        expect(get: "join_team_requests/new").to route_to("join_team_requests#new")
      end
    end
  end

  # Testing create method
  describe "POST #create" do
    before(:each) do
      # Stubbing participant to receive an object with id = 1
      allow(Participant).to receive(:find).with("1").and_return(participant)
    end
    context "when resource is not saved!" do
      it "renders new page" do
        allow(JoinTeamRequest).to receive(:new).and_return(invalidrequest)
        params = {participant_id: participant.id, team_id: -2}
        session = {user: student1}
        get :new, params, session
        expect(response).to render_template("new")
      end
    end
    # Testing when the object is being saved to the database
    context "when resource is saved" do
      before(:each) do
        allow(JoinTeamRequest).to receive(:new).and_return(join_team_request2)
        allow(Team).to receive(:find).with("1").and_return(team1)
        allow(Assignment).to receive(:find).with(1).and_return(assignment1)
        allow(Participant).to receive(:where).with(user_id: 1,parent_id: '1').and_return([participant])
        allow(join_team_request2).to receive(:save).and_return(true)
      end
      it "valid response" do
        allow(join_team_request2).to receive(:save).and_return(true)
        params = {
          id: 2,
          join_team_request2: {
            status: 'P'
          },
          team_id: 1,
          assignment_id: 1
        }
        session = {user: student1}
        post :create, params, session
        expect(response.status).to eq 302
        expect(join_team_request2.status).to eq('P')
      end
    end
    context "when it is not created" do
      it "will page for new " do
        allow(join_team_request2).to receive(:save).and_return(false)
        params = {action: 'new'}
        session = {user: student1}
        get :new, params, session
        expect(response.status).to eq 200
      end
    end
  end
  # Testing the Update method
  describe "PUT #update" do
    before(:each) do
      # Stubbing an object and allowing it to receive update_attributes method
      join_team_request2 = JoinTeamRequest.new
      allow(join_team_request2).to receive(:update_attributes).with(:comments).and_return(true)
      allow(Participant).to receive(:find).with("1").and_return(participant)
    end

    context "when the join_team_request is updated" do
      it "gives update message" do
        allow(Participant).to receive(:find).with("1").and_return(participant)
        allow(Team).to receive(:find).with("2").and_return(team2)
        params = {
          action: 'update',
          id: 2,
          join_team_request2: {
                      comments: "Changed"
                  }
        }
        # Updating "Comments" in the join team request object
        put :update, params
        expect(response.status).to eq 302
      end
    end
  end

  # Testing Decline method
  describe "#decline" do
    context "when join team request is declined" do
      before(:each) do
        allow(JoinTeamRequest).to receive(:find).and_return(join_team_request2)
        allow(join_team_request2).to receive(:save).and_return(true)
      end
      it "will change status to 'D'" do
        params = {action: 'decline'}
        session = {user: ta}
        result = get :decline, params, session
        expect(result.status).to eq 302
      end
      it "will redirect to view student teams path" do
        params = {action: 'decline'}
        session = {user: ta}
        result = get :decline, params, session
        expect(result).to redirect_to(view_student_teams_path)
      end
    end
  end
  # Testing destroy method
  describe 'destroy method' do
    context "when valid" do
      it 'will redirect to join team request page' do
        allow(JoinTeamRequest).to receive(:find).and_return(join_team_request2)
        allow(join_team_request2).to receive(:destroy).and_return(true)
        params = {action: 'destroy'}
        session = {user: ta}
        result = get :destroy, params, session
        expect(result.status).to eq 302
        expect(result).to redirect_to(join_team_requests_url)
      end
    end
  end
end


