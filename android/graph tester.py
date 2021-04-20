from neo4j import GraphDatabase, basic_auth
import json
def find_probability(a,b):
    return 10
driver = GraphDatabase.driver("bolt://3.86.89.41:7687",auth=basic_auth("neo4j", "tan-fights-invoice"))
user_id="8796a9e6-af8f-4001-b94e-8e53c6a9efa5"
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
    prob=find_probability(i+1,contact_properties[i])
    query2=f"MATCH (a:Person) WHERE a.id='{node_ids[i]}' SET a.probability={prob}"
    session=driver.session()
    session.run(query2)
print("hi")    
