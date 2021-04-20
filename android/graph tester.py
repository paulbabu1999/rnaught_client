from neo4j import GraphDatabase, basic_auth
driver = GraphDatabase.driver("bolt://3.86.89.41:7687",auth=basic_auth("neo4j", "tan-fights-invoice"))
user_id="8796a9e6-af8f-4001-b94e-8e53c6a9efa5"
query=f"MATCH (a:Person) WHERE a.id='{user_id}' Return a.probability"
session=driver.session()
val=session.run(query)
print(val.data()[0])