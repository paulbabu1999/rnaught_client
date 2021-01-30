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
    id,age,gender=data_recieved[id],data_recieved[age],data_recieved[gender]
    #db.add_newperson(id,age,gender)
    
    return jsonify({"id":id})

app.run(debug=True)    


