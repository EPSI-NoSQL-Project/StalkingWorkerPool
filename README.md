# StalkingWorkerPool
The worker pool that crawls the internet for information
If you want more details on the user interface, please refer to StalkingService.

You'll find below the system algorithm :

1- job "workers" put in Redis thanks to StalkingService.

2- We retrieve the couple "name" and "location" in Redis.

3- We launche each crawlers in a new thread and add information in ArangoDB.
The Available crawlers are : enjoygram, facebook, google, twitter, youtube

![alt tag](/screenshot/01_crawlers.png)

4- We wait for the threads to finish then we launch an ArangoDB query (AQL via Ruby) merge results.

5- We add the person in Elasticsearch for the autocomplte available in StalkingService.

![alt tag](/screenshot/02_elasticsearch.png)

Here is a assessment scheme :
![alt tag](/screenshot/00_schema.png)

We kept default ports for each database. Here is the recap list :
- ArangoDB : 8529
- Redis : 6379
- Elasticserach : 9200
- StalkingService : 9393




