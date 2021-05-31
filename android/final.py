import uuid
from flask import Flask,request,jsonify
from neo4j import GraphDatabase, basic_auth
from time import time,ctime
import datetime
import json
from collections import defaultdict
def current_time():
    d = datetime.datetime.now()
    month=d.strftime("%m")
    t=time()
    ltime=ctime(t).split(" ")
    atime=ltime[3].split(":")
    atime=int(atime[0])*60+int(atime[1])
    date=(int(ltime[-1])*10000+int(month)*100+int(ltime[2]))*3600
    ltime=date+atime
    return ltime


def find_probability(a):
    return .31 


    
    

    #to do:consider other factors to find probability
      
app=Flask(__name__)
people={}
id_new=0
driver = GraphDatabase.driver(
  "bolt://107.22.134.61:7687",
  auth=basic_auth("neo4j", "tube-spill-magazines"))

def runquery(q):
  session=driver.session()
  fr=session.run(q)
  return fr.data()
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
    
    user_id,connected_ids,temperature,humidity=data_recieved['user_id'],data_recieved['connections'], data_recieved['temperature'],data_recieved['humidity']
    
    
    
    for m in connected_ids:
        duration=connected_ids[m]
        query="MATCH (x{id:"+f"'{user_id}'"+"})-[r:contact]-(z{id:"+f"'{m}'"+"}) RETURN properties(r)"
        session=driver.session()
        fr=session.run(query)
        fr= fr.data()
        if fr:
            fr=fr[0]['properties(r)']['contact_times']
            fr=fr.split("\n")
            fr.append(f"{current_time()}:{duration}")
            contact_time_list="\n".join(fr)
            q="MATCH  (:Person {id:"+f"'{user_id}'"+"})-[r:contact]-(:Person {id:"+f"'{m}'"+"}) Set r.contact_times="+f"'{contact_time_list}'"
            session=driver.session()
            session.run(q)
        else:
            contact_time_list=f"{current_time()}:{duration}"
            query=f"MATCH (a:Person), (b:Person) WHERE a.id ='{user_id}'AND b.id = '{m}' CREATE (a)-[r:contact " +"{"+f"dur:0, humidity:'{humidity}',temperature:'{temperature}',contact_times:'{contact_time_list}'"+"}]->(b)"
            session=driver.session()
            session.run(query)

    
    
    return jsonify(200)

@app.route("/probability",methods=['POST']) 
def check_probability():
    val=0
    virus_type=None
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id=data_recieved['user_id']
    
    query=f"MATCH (n:Person) WHERE n.id='{user_id}' Return n.probability,labels(n)"
    session=driver.session()
    fr=session.run(query)
    fr= fr.data()
    virus_type=[]
    if fr:
        fr=fr[0]
        val=fr['n.probability']
        val=int(val*100)
        for i in fr['labels(n)']:
            if i=="Positive" or i=="Person":
                continue

            virus_type.append(i)
            
    return jsonify(val,virus_type)
    
@app.route("/positive",methods=['POST'])
def is_positive():
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id,virus_type=data_recieved['user_id'],data_recieved['virus_type']
      
    #query=f"MATCH (a:Person) WHERE a.id='{user_id}' Return a.probability"
    #session=driver.session()
    #val=session.run(query)
    #val=val.data()
    #val=val[0]
    #val=val["a.probability"]
    #if val<.05:
         
        # findsource(user_id)
      #  pass
    q=f"match(u) where u.id='{user_id}' return labels(u)"
    fr=runquery(q)[0]['labels(u)']
    temp=":".join(fr)
    temp="u:"+temp
    q=f"match(u) where u.id='{user_id}' remove {temp} set u:Positive:{virus_type} set u.probability=1"
    runquery(q)
 
    query="CALL apoc.export.json.query("
    q="MATCH p=({id:"+f"'{user_id}'"+"})-[r:contact*..5]-(fr) return relationships(p),length(p),nodes(p)"
    query="\"%s\""%q
    query="CALL apoc.export.json.query("+query+",null,{"+"stream:true})YIELD data "
    print(q)
    fr=runquery(query)
    fr=fr[0]['data']

    if fr:
    
        fr=fr.split("\n")
        fr=list(map(json.loads,fr))
        
        for i in fr:
            
            if i['length(p)']>1:
                pass 
            else:
                first_contact_times=i['relationships(p)'][-1]['properties']['contact_times'].split("\n")
                id_start=i['relationships(p)'][-1]['start']['id']
                id_end=i['relationships(p)'][-1]['end']['id']
                q=f"match(u) where id(u)={id_start} return labels(u),u.probability"
                q_res=runquery(q)[0]
                labels_start=q_res['labels(u)']
                prob_start=q_res['u.probability']
                q=f"match(u) where id(u)={id_end} return labels(u),u.probability"
                q_res=runquery(q)[0]
                labels_end=q_res['labels(u)'] 
                prob_end=q_res['u.probability']

                if current_time()-int(first_contact_times[-1].split(":")[0])<14*3600 and prob_start!=prob_end:
                    prob=find_probability(i['relationships(p)'][-1]['properties'])
                    if prob_start<prob_end and prob_start<prob:
                        q=f"MATCH (a:Person) WHERE id(a)={id_start} SET a.probability={prob} set a:{virus_type}"
                        runquery(q)
                    elif prob_end<prob:
                        q=f"MATCH (a:Person) WHERE id(a)={id_end} SET a.probability={prob} set a:{virus_type}"
                        runquery(q)


    return jsonify(201)
@app.route("/police",methods=['POST'])
def police():
    d={}
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8")) 
    connections=data_recieved['connections']
     
    for i,j in connections.items():
        if int(j)>-100:
            query=f"MATCH (a:Person) WHERE a.id='{i}' Return a.probability"
            session=driver.session()
            val=session.run(query) 
            val=val.data()
            if len(val)>0:
                val=val[0] 
                val=val["a.probability"]
                d[i]=val

    return jsonify(d)
app.run(debug=True,host='0.0.0.0',port=5000)   