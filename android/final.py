import uuid
from flask import Flask,request,jsonify
from neo4j import GraphDatabase, basic_auth
from time import time,ctime

import json

app=Flask(__name__)
people={}
id_new=0
driver = GraphDatabase.driver("bolt://3.86.89.41:7687",auth=basic_auth("neo4j", "tan-fights-invoice"))

@app.route("/register",methods=['POST'])
def register_user():
    data_recieved =request.data
   
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    
    age,gender=data_recieved['age'],data_recieved['gender']
    user_id = uuid.uuid4()
    
    query=f" id:'{user_id}', age: {age},gender: {gender}"
    query="CREATE (n:Person {"+query+"})"
    session=driver.session()
    session.run(query)
    #print(data_recieved," user created")#test
    return jsonify({"id":user_id})
prev_ids={}
@app.route("/new_contact",methods=['POST'])
def new_contact():
    data_recieved =request.data
    
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    
    user_id,connected_ids,disconnected_ids,temperature,location,humidity=data_recieved['user_id'],data_recieved['connections'],data_recieved["disconnections"], data_recieved['temperature'],data_recieved['location'],data_recieved['humidity']
    
    t=time()
    ltime=ctime(t).split(" ")
    ltime=" ".join(ltime[1:])
    for i in connected_ids:
        query=f"MATCH (a:Person), (b:Person) WHERE a.id ='{user_id}'AND b.id = '{i}'CREATE (a)-[r:contact " +"{"+f"start:'{ltime}',location:'{location}',humidity:'{humidity}',temperature:'{temperature}'"+"}]->(b)"
        session=driver.session()
        session.run(query)
    for i in disconnected_ids:
        query=f"MATCH (a"+"{"+f"id:'{user_id}'"+"})-[r]-(b"+"{"+f"id:'{i}'"+"})"+ f"SET r.end='{ltime}'"

        session=driver.session()
        session.run(query)



    #db.new_contact(id1,id2,duration,location)
    
    
    return 200
@app.route("/probability",methods=['POST']) 
def check_probability():
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id=data_recieved['id']
    #val=db.get_probability(id)
    query=f"MATCH (a:Person) WHERE a.id='{user_id}'' Return a.probablity"
    session=driver.session()
    val=session.run(query)
    print("id=",user_id)#test
    return jsonify({"probability":val})
@app.route("/positive",methods=['POST'])
def is_positive():
    
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id=data_recieved['id']
    
    query="CALL apoc.export.json.query("
    q="MATCH p=(u{id:"+f"'{user_id}'"+"})-[:contact*..5]->(fr) RETURN relationships(p)"

    query="\"%s\""%q
    query="CALL apoc.export.json.query("+query+",null,{"+"stream:true})YIELD data "
    query1="MATCH(u{" +f"id:'{user_id}'"+"})-[:contact*..5]->(fr) RETURN fr.id"
    print(query)
    session=driver.session()
    myResult = session.run(query1) 
    b=[]
    b1=[]
    for i in myResult:
        b1.append(i)
    for i in b1:
        b.append(i.data())  
    node_ids=[]
    for i in b:
        node_ids.append(i['fr.id'])
    print(node_ids)    
    session=driver.session()
    fr=session.run(query)
    for i in fr:
        a=i[0].split("\n")
    a=a[-1]
    a=json.loads(a)
    a=a["relationships(p)"]
    a1=[]
    for i in a:
        a1.append(i["properties"])
    contact_properties=a1    
     
    for i in range(len(node_ids)):
        prob=find_probability(i+1,contact_properties[j])
        query2=f"MATCH (a:Person) WHERE a.id='{node_ids[i]}'' SET a.probablity={prob}"
        session=driver.session()
        session.run(query2)
    #update probability
    return 201


def find_probability(level,contact_details):
    probability=.9/level**1.5

    #to do:consider other factors to find probability
    return probability                




app.run(debug=True,host='0.0.0.0',port=5000)    

