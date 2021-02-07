from flask import Flask,request,jsonify
import json
app=Flask(__name__)
people={}
id_new=0

@app.route("/id",methods=['GET'])
def new_id():
    global id_new
    id_new+=1
    d={}
    d["id"]=id_new
    return jsonify(d)


@app.route("/add_person",methods=['POST'])
def add_newperson():
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    id,age,gender=data_recieved['id'],data_recieved['age'],data_recieved['gender']
    #db.add_newperson(id,age,gender)
    print(data_recieved)#test
    return jsonify({"id":id})
@app.route("/new_contact",methods=['POST'])
def new_contact():
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    id1,id2,duration,location=data_recieved['id1'],data_recieved['id2'],data_recieved['duration'],data_recieved['location']
    #db.new_contact(id1,id2,duration,location)
    print(data_recieved)#test
    return 200
@app.route("/probability",methods=['POST']) 
def check_probability():
    val=50
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    id=data_recieved['id']
    #val=db.get_probability(id)
    print("id=",id)#test
    return jsonify({"probability":val})
@app.route("/positive",methods=['POST'])
def is_positive:
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    id=data_recieved['id']
    print("id=",id)#test
    #db.is_positive(id) 
    return 201



def find_probability(level,duration):
    probability=.9/level**1.5

    if duration>120:
        probability=probability+.1
    elif duration>60:
        probability=probability+.07
    elif duration>30:
        probability=probability+.05
    else :
        probability=probability+.01*duration/100
    return probability                



def new_contact
app.run(debug=True)    


