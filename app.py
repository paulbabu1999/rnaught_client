from flask import Flask,request
from flask_restful import Api,Resource,reqparse
app=Flask(__name__)
api=Api(app)
people={}
new_person_put_args=reqparse.RequestParser()
new_person_put_args.add_argument("id",type=int,required=True)
new_person_put_args.add_argument("age",type=int)
new_person_put_args.add_argument("gender",type=int)
class add_person(Resource):
    def get(self,id):
        return people[id]
    def put(self,id):
        args=new_person_put_args.parse_args()
        #add to database
        people[id]=args
        return people[id],201  
#add new person request   
api.add_resource(add_person,"/add_person/<int:id>")     
@app.route('/id', methods=['GET'])
def returnAll():
    return jsonify({'id':1})


app.run(debug=True)
    