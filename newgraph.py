from flask import Flask,request,jsonify
from neo4j import GraphDatabase,basic_auth
import py2neo
import json
from py2neo import Graph
app=Flask(__name__)
people={}
id_new=0
driver = GraphDatabase.driver(
  "bolt://3.92.180.117:7687",
  auth=basic_auth("neo4j", "books-rack-leads"))
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
    id,age,gender=data_recieved['id'],data_recieved['age'],data_recieved['gender']
    #db.add_newperson(id,age,gender)
    graph= Graph()
    tx=graph.cypher.begin()    
    tx.append("CREATE (:Person {id: $id},{age: $age},{gender: $gender})", id=id, age=age, gender=gender)
    tx.commit()
    print(data_recieved)#test
    return jsonify({"id":id})
@app.route("/new_contact",methods=['POST'])
def new_contact():
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    id1,id2,duration,location=data_recieved['id1'],data_recieved['id2'],data_recieved['duration'],data_recieved['location']
    #db.new_contact(id1,id2,duration,location)
    graph= Graph()
    tx=graph.cypher.begin()
    tx.run("MATCH (id1:Person {id1: $id1}) "
               "MATCH (id2:Person {id2: $id2}) "
               "MERGE (id1)<-[:CAME IN CONTACT]->(id2)",
               id1=id1, id2=id2)
    tx.commit()
    print(data_recieved)#test
    return 200
@app.route("/probability",methods=['POST']) 
def check_probability():
    val=50
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    id=data_recieved['id']
    #val=db.get_probability(id)
    graph= Graph()
    tx=graph.cypher.begin()
    probability=tx.run("MATCH(id : $id) RETURN probablity(id)")
    tx.commit()    
    print("id=",id)#test
    return jsonify({"probability":val})
@app.route("/positive",methods=['POST'])
def is_positive:
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    id=data_recieved['id']
    print("id=",id)#test
    graph= Graph()
    tx=graph.cypher.begin()
    tx.run("MATCH (a:Person) WHERE id(a) = $id SET a.conditon = positive")
    tx.commit()
    probablity=find_probablity(1,60)
    tx.run("MATCH ({id : $id})-[*]-(connected)"
           "SET connected.probability=$probability",probablity=probablity)
    tx.commit()
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
