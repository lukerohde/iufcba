require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe PeopleController do

  # This should return the minimal set of attributes required to create a valid
  # Person. As you add validations to Person, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { FactoryGirl.attributes_for(:person, union_id: FactoryGirl.create(:union).id, email: 'test@iuf.org', authorizer: admin) }
  let(:invalid_attributes) do
    { email: "invalid.email.com" }
  end

  describe "Security" do
    describe "low privilege" do
      login_person

      describe "Get JSON index" do
        it "only returns people from user's union" do
          # User should only be able to choose people from their own union
          outsider = Person.create! valid_attributes
          insider = Person.create! FactoryGirl.attributes_for(:authorized_person, union_id: subject.current_person.union.id)
          scoped_get :index, {format: 'json'}
          expect(assigns(:people)).to eq([subject.current_person]+[insider])
        end
      end

      describe "access to" do

        describe "outsiders" do
          before(:each) do
            @outsider = Person.create! valid_attributes
          end

          # it "won't allow viewing of outsiders" do
          #   scoped_get :show, {id: @outsider.to_param}
          #   expect(response).to be_forbidden
          # end

          it "won't allow editing of outsiders" do
            scoped_get :edit, {id: @outsider.to_param}
            expect(response).to be_forbidden
          end

          it "won't allow updating outsiders" do
            scoped_put :update, {id: @outsider.to_param, person: { first_name: "bob"} }
            expect(response).to be_forbidden
          end
        end

        describe "colleagues" do
          before(:each) do
            @insider = Person.create! FactoryGirl.attributes_for(:authorized_person, union_id: subject.current_person.union.id)
          end

          it "won't allow deleting of people" do
            expect {
              scoped_delete :destroy, { :id => @insider.to_param }
              expect(response).to be_forbidden
            }.to change(Person, :count).by(0)
          end

          # it "will allow viewing colleagues" do
          #   scoped_get :show, {id: @insider.to_param}
          #   expect(response).to be_successful
          #   response.should render_template(:show)
          # end

          it "will allow editing colleagues" do
            scoped_get :edit, {id: @insider.to_param}
            expect(response).to be_successful
            expect(response).to render_template(:edit)
          end

          it "will allow updating of colleagues" do
            scoped_put :update, {id: @insider.to_param, person: { first_name: "bob"} }
            expect(response).to redirect_to(people_path)
          end
        end
      end
    end

    describe "High privilege access" do
      login_admin

      describe "Get JSON index" do
          it "returns all people" do
          # User should only be able to choose people from their own union
          outsider = Person.create! valid_attributes
          insider = Person.create! FactoryGirl.attributes_for(:authorized_person, union_id: subject.current_person.union.id)
          scoped_get :index, {format: 'json'}
          expect(assigns(:people)).to eq([subject.current_person]+[outsider]+[insider])
        end
      end
    end
  end

  describe "Basic Functionality" do
    login_admin

    describe "GET index" do
      it "assigns all people as @people" do
        person = Person.create! valid_attributes
        scoped_get :index
        expect(assigns(:people)).to eq([subject.current_person]+[person])
      end

      it "filters by name and division" do
        person1 = Person.create! valid_attributes
        person2 = Person.create! valid_attributes.merge(first_name: "Bust", last_name: "Buster", email: "buster@iuf.org")
        person2.union = owner_union

        scoped_get :index, { format: 'json', name_like: 'Bust' }

        expect(assigns(:people)).to include(person2)
        expect(assigns(:people)).not_to include(person1)

        @division = Division.first

        scoped_get :index, { format: 'json' }

        expect(assigns(:people).size).to be(1)
      end
    end

    # describe "GET show" do
    #   it "assigns the requested person as @person" do
    #     person = Person.create! valid_attributes
    #     scoped_get :show, {:id => person.to_param}
    #     assigns(:person).should eq(person)
    #   end
    # end

    describe "GET edit" do
      it "assigns the requested person as @person" do
        person = Person.create! valid_attributes
        scoped_get :edit, {:id => person.to_param}
        expect(assigns(:person)).to eq(person)
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested person" do
          person = Person.create! valid_attributes
          # Assuming there are no other people in the database, this
          # specifies that the Person created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          #Person.any_instance.should_receive(:update).with({ "firstname" => "MyString" })
          #expect_any_instance_of(Person).to receive(:update).with({ "firstname" => "MyString" })
          scoped_put :update, {:id => person.to_param, :person => { "first_name" => "MyString" }}
          person.reload
          expect(person.first_name).to eq("MyString")
        end

        it "assigns the requested person as @person" do
          person = Person.create! valid_attributes
          scoped_put :update, {:id => person.to_param, :person => valid_attributes}
          expect(assigns(:person)).to eq(person)
        end

        it "redirects to the person" do
          person = Person.create! valid_attributes
          scoped_put :update, {:id => person.to_param, :person => valid_attributes}
          expect(response).to redirect_to(people_path)
        end
      end

      describe "with invalid params" do
        it "assigns the person as @person" do
          person = Person.create! valid_attributes
          # Trigger the behavior that occurs when invalid params are submitted
          #Person.any_instance.stub(:save).and_return(false)
          scoped_put :update, {:id => person.to_param, :person => invalid_attributes}
          updated = Person.find(person.id)
          expect(updated.email).to eq(person.email)
        end

        it "re-renders the 'edit' template" do
          person = Person.create! valid_attributes

          # test failure on invalid_params
          scoped_put :update, {:id => person.to_param, :person => invalid_attributes}
          expect(response).to render_template("edit")

          # test other failure on save
          allow_any_instance_of(Person).to receive(:save).and_return(false)
          scoped_put :update, {:id => person.to_param, :person => valid_attributes}
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested person" do
        person = Person.create! valid_attributes
        expect {
          scoped_delete :destroy, { :id => person.to_param }
        }.to change(Person, :count).by(-1)
      end

      it "redirects to the people list" do
        person = Person.create! valid_attributes
        scoped_delete :destroy, { :id => person.to_param }
        expect(response).to redirect_to(people_url)
      end
    end
  end
end
