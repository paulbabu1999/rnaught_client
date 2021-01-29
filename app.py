from flask import Flask,request
from flask_restful import Api,Resource,reqparse
app=Flask(__name__)
api=Api(app)
people={}
id_new=0

#generate id
class generate_id(Resource):

    def get(self):
        global id_new
        id_new+=1
        return {"id":id_new}

api.add_resource(generate_id,"/id")



new_person_put_args=reqparse.RequestParser()
new_person_put_args.add_argument("id",type=int,required=True)
new_person_put_args.add_argument("age",type=int,required=True)
new_person_put_args.add_argument("gender",type=int,required=True)
#add new person request 
class add_person(Resource):
    
    def put(self):
        args=new_person_put_args.parse_args()
        #add to database
        people[id]=args#not required,temporary
        db.add_newperson(args)
        return 201  #201 status code for created.
#add new person request   
api.add_resource(add_person,"/add_person")   


#new relation-contact
new_contact_put_args=reqparse.RequestParser()
new_contact_put_args.add_argument("id1",type=int,required=True)
new_contact_put_args.add_argument("id2",type=int,required=True)
new_contact_put_args.add_argument("time",type=int,required=True)
new_contact_put_args.add_argument("location",type=int,required=True)
class new_contact(Resource):
    def put(self):
        ar=new_person_put_args.parse_args()
        db.newcontact(ar)
        return 201


api.add_resource(new_contact,"/new_contact")  

#predict the probability
class predict(Resource):
    def get(self,id):
        p=db.get_probability(id)#gets probability value from neo4j node
        return {"probability":p}

api.add_resource(predict,"/<int:id>")

app.run(debug=True)
    