import uuid
from flask import Flask,request,jsonify
from neo4j import GraphDatabase, basic_auth
from time import time,ctime
import datetime
import json
def find_probability(level,contact_details):
    probability=.9/level**1.5
    

    #to do:consider other factors to find probability
    return probability   
app=Flask(__name__)
people={}
id_new=0
driver = GraphDatabase.driver("bolt://3.86.89.41:7687",auth=basic_auth("neo4j", "tan-fights-invoice"))

@app.route("/register",methods=['POST'])
def register_user():
    probability=0
    data_recieved =request.data
   
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    age,gender=data_recieved['age'],data_recieved['gender']
    user_id = uuid.uuid4()
    
    query=f" id:'{user_id}', age: {age},gender: '{gender}',probability: {probability}"
    query="CREATE (n:Person {"+query+"})"
    session=driver.session()
    session.run(query)
    #print(data_recieved," user created")#test
    return jsonify({"user_id":user_id})
prev_ids={}

@app.route("/new_contact",methods=['POST'])
def new_contact():
    data_recieved =request.data
    
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    
    user_id,connected_ids,disconnected_ids,temperature,humidity=data_recieved['user_id'],data_recieved['connections'],data_recieved["disconnections"], data_recieved['temperature'],data_recieved['humidity']
    
    disconnected_ids=list(disconnected_ids)
    d = datetime.datetime.now()
    month=d.strftime("%m")
    t=time()
    ltime=ctime(t).split(" ")
    atime=ltime[3].split(":")
    atime=int(atime[0])*60+int(atime[1])
    date=(int(ltime[-1])*10000+int(month)*100+int(ltime[2]))*3600
    ltime=date+atime
    for i,j in connected_ids.items():
        if j>-100:
            query=f"MATCH (a:Person), (b:Person) WHERE a.id ='{user_id}'AND b.id = '{i}'CREATE (a)-[r:contact " +"{"+f"start:{ltime},humidity:'{humidity}',temperature:'{temperature}'"+"}]->(b)"
            session=driver.session()
            session.run(query)
    for i in disconnected_ids:
        query="MATCH (a{"+f"id:'{user_id}'"+"})-[r]-(b{"+f"id:'{i}'"+"})"+ f"SET r.end={ltime}"

        session=driver.session()
        session.run(query)



    #db.new_contact(id1,id2,duration,location)
    
    return jsonify(200)

@app.route("/probability",methods=['POST']) 
def check_probability():
    val=0
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id=data_recieved['user_id']
    #val=db.get_probability(id)
    print("hi")
    query=f"MATCH (a:Person) WHERE a.id='{user_id}' Return a.probability"
    session=driver.session()
    val=session.run(query)
    
    return jsonify(val.data()[0])
    
@app.route("/positive",methods=['POST'])
def is_positive():
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id=data_recieved['user_id']
    
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
    if len(a)>2:
        a=json.loads(a)
        a=a["relationships(p)"]
        a1=[]
        for i in a:
            a1.append(i["properties"])
        contact_properties=a1    
        
        for i in range(len(node_ids)):
            prob=find_probability(i+1,contact_properties[i])
            query2=f"MATCH (a:Person) WHERE a.id='{node_ids[i]}' SET a.probability={prob}"
            session=driver.session()
            session.run(query2)
        #update probability
    return jsonify(201)

app.run(debug=True,host='0.0.0.0',port=5000)   