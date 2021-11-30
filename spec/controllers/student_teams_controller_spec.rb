require './spec/support/teams_shared.rb'

describe StudentTeamsController do
  include_context 'object initializations'
  include_context 'authorization check'


  let(:student_teams_controller) { StudentTeamsController.new }
  let(:student) { double "student" }
  describe '#view' do
    it 'sets the student' do
      allow(AssignmentParticipant).to receive(:find).with('12345').and_return student
      allow(student_teams_controller).to receive(:current_user_id?)
      allow(student_teams_controller).to receive(:params).and_return(student_id: '12345')
      allow(student).to receive(:user_id)
      student_teams_controller.view
    end
  end

  describe 'POST #create' do
    before(:each) do
      @student = AssignmentParticipant.new
    end
    context 'when create Assignment team' do
      it 'flash notice when team is empty' do
        allow(AssignmentTeam).to receive(:where).with(name: '', parent_id: 1).and_return(nil)
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        allow(student1).to receive(:user_id)
        session = {user:student1}
        params = {
          student_id:1,
          team:{
            name:'test'
          }
        }
        result= post :create, params, session
        expect(result.status).to eq 302
      end
    end
    context "create team" do
      it "saves the team" do
        allow(AssignmentNode).to receive(:find_by).with(node_object_id: 1).and_return(node1)
        allow(AssignmentTeam).to receive(:new).with(name: 'test', parent_id: 1).and_return(team7)
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        allow(student1).to receive(:user_id)
        allow(team7).to receive(:save).and_return(true)
        session = {user:student1}
        params = {
          student_id:1,
          team:{
            name:'test'
          }
        }
        result= post :create, params, session

        expect(result.status).to eq(302)

      end
    end
    context "name already in use" do
      it "flash notice" do
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return(team7)
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        allow(student1).to receive(:user_id)
        session = {user:student1}
        params = {
          student_id:1,
          team:{
            name:'test'
          }
        }
        result= post :create, params, session
        expect(result.status).to eq 302
      end
    end
  end

  describe '#update' do
    context 'update team name' do
      it 'update name' do
        allow(AssignmentParticipant).to receive(:find).and_return(participant)
        allow(AssignmentTeam).to receive(:find).and_return(team7)
        allow(AssignmentTeam).to receive(:where).with(name: 'test', parent_id: 1).and_return(team7)
        allow(team7).to receive(:destroy_all)
        allow(student1).to receive(save).and_return(true)
        session = {user:student1}
        params = {
          student_id:1,
          team:{
            name:'test'
          }
        }
        result= post :update, params, session
        expect(result.status).to eq(302)
      end
    end
  end

  describe '#remove_participant' do
   context 'remove team user' do
     it 'remove user' do
    allow(AssignmentParticipant).to receive(:find).and_return(participant)
    allow(TeamsUser).to receive(:where).and_return(team_user1)
    allow(team_user1).to receive(:destroy_all)
    allow(team_user1).to receive_message_chain(:where,:empty?).and_return(false)
    allow_any_instance_of(AssignmentParticipant).to receive(:save).and_return(false)
    session = {user:student1}
    params = {
      team_id:1,
      user_id:1,
      student_id:1,
      team:{
        name:'test'
      }
    }
    result = post :remove_participant, params, session
    expect(result.status).to eq 302
    # expect(result).to redirect_to(view_student_teams_path(:student_id => 1))
     end
   end

  end
end
