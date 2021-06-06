import uuid
from flask import Flask,request,jsonify
from neo4j import GraphDatabase, basic_auth
from datetime import datetime
import json
from collections import defaultdict
def current_time():
    now = datetime.now()
 
    

    # dd/mm/YY H:M:S
    dt_string = now.strftime("%d %m %Y %H %M %S")
    dt_string=list(map(int,dt_string.split(" ")))
    
    ltime=dt_string[-2]+dt_string[-3]*60 + dt_string[0]*3600+dt_string[1]*3600*30+dt_string[2]*365*3600
    return ltime


def find_probability(a):
    return .92/int(a[1])

 
    
    

    #to do:consider other factors to find probability
      
app=Flask(__name__)
people={}
id_new=0 
driver = GraphDatabase.driver(
  "bolt://107.22.134.61:7687",
  auth=basic_auth("neo4j", "tube-spill-magazines"),max_connection_lifetime=200)

def runquery(q):
  session=driver.session()
  fr=session.run(q)
  return fr.data()
def findsource(user_id,virus_type):
    source=None
    query="CALL apoc.export.json.query("
    q="MATCH(a:Person { "+f"id: '{user_id}' "+"}),(b:"+f"{virus_type}),p = shortestPath((a)-[r:contact*]-(b)) return r"
    query="\"%s\""%q
    query="CALL apoc.export.json.query("+query+",null,{"+"stream:true})YIELD data "
    print(query)
    
    fr=runquery(query)[0]['data']
    if len(fr)==0:
      return None
    fr=fr.split("\n")
    fr=min(fr, key = len)
    fr=json.loads(fr)
    fr=fr['r']
    print(fr)
    q="match(n{id:"+f"'{user_id}'"+"}) return id(n)"
    val=runquery(q)[0]['id(n)']
    visited=set()
    
    visited.add(str(val))
    prev={}
    i=fr[0]  
    contact_time=(i['properties']['contact_times']).split("\n")[-1]
    if i['start']['id'] in visited:
      
      prev[i['end']['id']]=int(contact_time.split(":")[0])
      visited.add(i['end']['id'])

    else:
      prev[i['start']['id']]=int(contact_time.split(":")[0])
      visited.add(i['start']['id'])
    for i in fr[1:]:
      contact_time=int(((i['properties']['contact_times']).split("\n")[0]).split(":")[0])
      if i['start']['id'] in visited:
        end_id=i['end']['id']
        visited.add(i['end']['id'])
        start_id=i['start']['id']
      else:
        end_id=i['start']['id']
        visited.add(i['start']['id'])
        start_id=i['end']['id']
      if contact_time<=prev[start_id]:
        prev[end_id]=int(((i['properties']['contact_times']).split("\n")[-1]).split(":")[0])  
      else:
        source=end_id
        return source  
    return source


def five_level(user_id,virus_type):
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
        dat=[]
        visited=set()
        prev_times={}
        for i in fr:
            dat.append((i['relationships(p)'][-1],i['length(p)']))
        dat.sort(key=lambda x:x[1])    
        for i in dat:    
            if i[1]>1:
                if i[0]['start']['id'] in visited and i[0]['end']['id'] in visited:#checks if already in previous lvl
                    continue
                if i[0]['start']['id'] in prev_times :
                    id_start=i[0]['start']['id'] 
                    id_end=i[0]['end']['id']                           #finds the id of start node and end node
                elif i[0]['end']['id'] in prev_times:
                    id_start=i[0]['end']['id']
                    id_end=i[0]['start']['id'] 
                else:
                    continue
                visited.add(id_end)
                first_contact_times=i[0]['properties']['contact_times'].split("\n")
                temp=[]
                for p in first_contact_times:
                    temp.append(int(p.split(":")[0]))
                flag=0
                first_contact_times=temp
                
                for j in range(len(first_contact_times)): 
                    if first_contact_times[j]>=prev_times[id_start]:
                        contact_time=first_contact_times[j]
                        flag=1
                        break
                if flag:    
                    prob=find_probability(i)  
                    q=f"match(u) where id(u)={id_end} return labels(u),u.probability"
                    q_res=runquery(q)[0]
                    prob_end=q_res['u.probability']
                    if prob>prob_end:
                        prev_times[id_end]=contact_time
                        q=f"MATCH (a:Person) WHERE id(a)={id_end} SET a.probability={prob} set a:{virus_type}"
                        runquery(q)




              

            else:
                first_contact_times=i[0]['properties']['contact_times'].split("\n")
                id_start=i[0]['start']['id']
                id_end=i[0]['end']['id']
                visited.add(id_end)
                visited.add(id_start)
                q=f"match(u) where id(u)={id_start} return labels(u),u.probability"
                q_res=runquery(q)[0]
                labels_start=q_res['labels(u)']
                prob_start=q_res['u.probability']
                q=f"match(u) where id(u)={id_end} return labels(u),u.probability"
                q_res=runquery(q)[0]
                labels_end=q_res['labels(u)'] 
                prob_end=q_res['u.probability']
                
                if current_time()-int(first_contact_times[-1].split(":")[0])<14*3600 and prob_start!=prob_end:
                    prob=find_probability(i)
                    print(prob_end,prob_start)
                    if prob_start<prob_end and prob_start<prob:
                        prev_times[id_start]=int(first_contact_times[-1].split(":")[0])
                        q=f"MATCH (a) WHERE id(a)={id_start} SET a.probability={prob} SET a:{virus_type}"
                        runquery(q)
                    elif prob_end<prob:
                        prev_times[id_end]=int(first_contact_times[-1].split(":")[0])
                        
                        q=f"MATCH (a) WHERE id(a)={id_end} SET a.probability={prob} SET a:{virus_type}"
                        runquery(q)
    ##print(visited,prev_times)
    return jsonify(201)
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


@app.route("/new_contact",methods=['POST'])
def new_contact():
    data_recieved =request.data
    data_recieved=data_recieved.decode("utf-8")
    
    data_recieved=json.loads(data_recieved)
    
    user_id,connected_ids,temperature,humidity=data_recieved['user_id'],data_recieved['connections'], data_recieved['temperature'],data_recieved['humidity']
    
    
    
    for m in connected_ids:
        duration=connected_ids[m]
        m = m.lower()
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

    
    print(contact_time_list)
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
    virus_type={}
    if fr:
        fr=fr[0]
        val=fr['n.probability']
        val=int(val*100)
        for i in fr['labels(n)']:
            if i=="Positive" or i=="Person":
                continue

            virus_type[i]=val
    if len(virus_type)==0:
        virus_type={"No Infection":0}
    print(virus_type)       
    return jsonify(virus_type)
    
@app.route("/positive",methods=['POST'])
def is_positive():
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8"))
    user_id,virus_type=data_recieved['user_id'],data_recieved['virus_type']
      
    query=f"MATCH (a:Person) WHERE a.id='{user_id}' Return a.probability"
    val=runquery(query)
    source=None
    if val:
        val=val[0]
        val=val["a.probability"]
        if val<.05:
            source=findsource(user_id,virus_type)
        if source!=None:
            q=f"match (n) where id(n)={source} return n.id"
            val=runquery(q)[0]['n.id']
            five_level(val,virus_type)
    return five_level(user_id,virus_type)


@app.route("/police",methods=['POST'])
def police():
    d={}
    data_recieved =request.data
    data_recieved=json.loads(data_recieved.decode("utf-8")) 
    connections=data_recieved['connections']
     
    for i,j in connections.items():
        i = i.lower()
        if int(j)>-100:
            query=f"MATCH (a:Person) WHERE a.id='{i}' Return a.probability"
            session=driver.session()
            val=session.run(query) 
            val=val.data()
            if len(val)>0:
                val=val[0] 
                val=val["a.probability"]
                val=int(val*100)
                d[i]=val
    if len(d)==0:
        d={"No Person Nearby":0}   
    print(d)
    return jsonify(d)
app.run(debug=True,host='0.0.0.0',port=5000)