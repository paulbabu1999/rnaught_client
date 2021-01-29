# pip3 install neo4j-driver
# python3 example.py

from neo4j import GraphDatabase, basic_auth

driver = GraphDatabase.driver(
  "bolt://100.25.155.63:32804",
  auth=basic_auth("neo4j", "expenditures-hilltop-nozzles"))

cypher_query = '''
MATCH (n) 
RETURN COUNT(n) AS count 
LIMIT $limit
'''

with driver.session(database="neo4j") as session:
  results = session.read_transaction(
    lambda tx: tx.run(cypher_query,
                      limit="10").data())
  for record in results:
    print(record['count'])

driver.close()
