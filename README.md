## Async SOQL Sample

Working with BigData requires re-thinking how you work on the Salesforce platform. Since you can assume that you're working with billions of records instead of thousands or even millions, common tasks like aggregate functions (e.g. Count()) or complex queries are difficult when you have only one index called a row key. However, the advantage working with BigData on the platform is that use cases involving billions of records are now achieveable for a variety of use cases including:

1. long term adoption metrics
2. audit
3. performance monitoring
4. archiving

As a result, it's better to think of BigData as a [data lake](https://en.wikipedia.org/wiki/Data_lake), where massive amounts of data can be processed asynchronously to meet any of the above use cases.

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/dataLake.png)

In the more concrete case of user login events which we now store in the Salesforce equivelent of BigData called a BigObject, it becomes important to understand how to work with the data at scale, especially since not all capabilities that we've come to expect like operational reports or workflow will be possible with a BigObject. It's a trade off of scale for limited platform capabilities.

For instance, rather than querying the BigObject using a convention like synchronous SOQL via the API for use in real-time applications, it's better to use a new convention called asynchronous SOQL which is now in pilot. 

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/LoginEvents.png)

For instance, you may want to create a subset or reduced set of data every hour, daily, or weekly in order to have the full transactionality of the Salesforce platform at your fingertips.

## Installation

The easiest way to install this project into your org is to make use of the workbench tool (http://workbench.developerforce.com).  

1. Download a ZIP of the repository. 
2. Uncompress the files. Find the src folder with the package.xml file in it. Re-zip it on the command line: 
```zip -r deploy.zip src```
3. Open Workbench (http://workbench.developerforce.com/) 
4. Login to the desired organization with a user that has Modify All Data.  
5. Select *Deploy* from the *migration* menu and when prompted, choose your zip file and select 'Allow Missing Files' checkbox before deploying it.


## Configuration and Usage

To run the scheduled jobs, you must assign the correct permissions to the user. An example permission set is included in this repository: LoginForensics permission set.

Remote Site Settings

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/samplePage.png)

Session Settings

Scheduled Jobs and Apex

Debug




## Credit

Contributors include:

* Adam Torman created and orchestrated the majority of the repository
* Adam Purkiss provided expert consultation as my phone-a-friend
* Eli Levine who created Asynchronous SOQL

This repo is As-Is. All pull requests are welcome.