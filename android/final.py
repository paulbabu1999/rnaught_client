import uuid
from flask import Flask,request,jsonify
from neo4j import GraphDatabase, basic_auth
from time import time,ctime
import datetime
import json
from collections import defaultdict

def find_probability(user_id,level,contact_details):
    query=f"MATCH (a:Person) WHERE id(a)={user_id} Return a.probability"
    session=driver.session()
    val=session.run(query)
    val=val.data()
    val=val[0]

    
    val=val["a.probability"]

    contact_details=defaultdict(int,contact_details)
    if contact_details["dur"]==0:
        probability=.8/level**1.2
    else:
        probability=.68/level**1.2+.1/level
    
        
    
    return val<probability,probability

    #to do:consider other factors to find probability
      
app=Flask(__name__)
people={}
id_new=0
driver = GraphDatabase.driver(
  "bolt://54.226.63.117:7687",
  auth=basic_auth("neo4j", "hugs-perforation-elbows"))


def findsource(user_id):
    q="MATCH(a:Person { "+f"id: '{user_id}' "+"}),(b:Person {positive: 'true'}),p = shortestPath((a)-[*]-(b)) Return p"
    session=driver.session()
    fr=session.run(q)

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
    return jsonify({"user_id":user_id})
prev_ids={}

@app.route("/new_contact",methods=['POST'])
def new_contact():
    data_recieved =request.data
    data_recieved=data_recieved.decode("utf-8")
    
    data_recieved=json.loads(data_recieved)
    
    user_id,connected_ids,disconnected_ids,temperature,humidity=data_recieved['user_id'],data_recieved['connections'],data_recieved['disconnections'], data_recieved['temperature'],data_recieved['humidity']
    
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
            q="MATCH  (a:Person { "+ f"id:'{user_id}'"+"}), (b:Person {id:"+f"'{i}' "+"}) RETURN EXISTS( (a)-[:contact]-(b) )"
            session=driver.session()
            fr=session.run(q)
            if (fr.data()[0]['EXISTS( (a)-[:contact]-(b) )']):
                q="MATCH  (:Person {id:"+f"'{user_id}'"+"})-[r:contact]-(:Person {id:"+f"'{i}'"+"}) Set r.new="+f"{ltime}"
                session=driver.session()
                session.run(q)

            
            else:
                query=f"MATCH (a:Person), (b:Person) WHERE a.id ='{user_id}'AND b.id = '{i}' CREATE (a)-[r:contact " +"{"+f"old:{ltime},new:{ltime},dur:0, humidity:'{humidity}',temperature:'{temperature}'"+"}]->(b)"
                session=driver.session()
                session.run(query)
    for i in disconnected_ids:
        k=0
        q="match(:Person{id:" f"'{user_id}'"+ " })-[r:contact]-(:Person{id:"+f"'{i}'"+"}) Return r.new"
        session=driver.session()
        fr=session.run(q)
        begin=fr.data()[0]['r.new']
        if ltime-begin>30:
            k=1
          

        query="MATCH (a{ "+f"id:'{user_id}'"+" })-[r]-(b{ "+f"id:'{i}'"+" }) "+ f" SET r.dur={k}"

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
    
    query=f"MATCH (a:Person) WHERE a.id='{user_id}' Return a.probability"
    session=driver.session()
    val=session.run(query)
    
    return jsonify(val.data()[0])
    
@app.route("/positive",methods=['POST'])
def is_positive():
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id=data_recieved['user_id']
    d = datetime.datetime.now()
    month=d.strftime("%m")
    t=time()
    ltime=ctime(t).split(" ")
    atime=ltime[3].split(":")   
    atime=int(atime[0])*60+int(atime[1])
    date=(int(ltime[-1])*10000+int(month)*12+int(ltime[2]))*24*60
    ltime=date+atime
    query=f"MATCH (a:Person) WHERE a.id='{user_id}' Return a.probability"
    session=driver.session()
    val=session.run(query)
    val=val.data()
    val=val[0]
    val=val["a.probability"]
    if val<.05:
        
       # findsource(user_id)
        pass

    query2="MATCH (a{"+ f"id:'{user_id}'"+"}) Set a+={probability:1,positive:'true'}"
    session=driver.session()
    session.run(query2)



    query="CALL apoc.export.json.query("
    q="MATCH p=(u{id:"+f"'{user_id}'"+"})-[:contact*..5]-(fr) RETURN relationships(p)"

    query="\"%s\""%q
    query="CALL apoc.export.json.query("+query+",null,{"+"stream:true})YIELD data "

    session=driver.session()
    fr=session.run(query)
    
    for i in fr:
        a=i[0].split("\n")
    
    if len(a[0]) >0:   
        contact_time_applicable={}    
        for i in a:
            
            i=json.loads(i)
            
            i=i["relationships(p)"]
            print(i)
            j=i[-1]
                
            lvl,c_id1,c_id2,contact_properties=len(i),j['end'] ,j['start'],j["properties"],#temp to store id of parent to check contact time
            temp1=c_id1["id"]
            temp2=c_id2["id"]
            contact_time_applicable[temp1]=contact_properties['old']#d contains id and contact time
            contact_time_applicable[temp2]=contact_properties['old']#d contains id and contact time

            c_id1=c_id1["id"]
            c_id2=c_id2["id"]
            
            
            k=0    
            if lvl==1 and ltime-contact_properties['new']<24*60*28:
                
                k=1
                e1,prob1=find_probability(c_id1,lvl,contact_properties)
                e2,prob2=find_probability(c_id2,lvl,contact_properties)
                if e1:
                    prob=prob1
                    e=e1
                    c_id=c_id1
   
                else:
                    prob=prob2
                    e=e2
                    c_id=c_id2
            elif lvl>1 and  contact_properties['new']>=contact_time_applicable[c_id]:
                
                k=1
                e1,prob1=find_probability(c_id1,lvl,contact_properties)
                e2,prob2=find_probability(c_id2,lvl,contact_properties)
                if e1:
                    e=e1
                    prob=prob1
                    c_id=c_id1
                else:
                    e=e2
                    prob=prob2
                    c_id=c_id2
            else:
                pass    
            
            if k==1 and e:
                
                query2=f"MATCH (a:Person) WHERE id(a)={c_id} SET a.probability={prob}"
                session=driver.session()
                session.run(query2)
    return jsonify(201)
@app.route("/police",methods=['POST'])
def police():
    d={}
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8")) 
    connections=data_recieved['connections']
    
    for i,j in connections.items():
        if j>-100:
            query=f"MATCH (a:Person) WHERE a.id='{i}' Return a.probability"
            session=driver.session()
            val=session.run(query)
            val=val.data()
            val=val[0]
            val=val["a.probability"]
            d[i]=val

    return jsonify(d)
app.run(debug=True,host='0.0.0.0',port=5000)   