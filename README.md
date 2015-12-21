## Async SOQL for Event Monitoring

Working with BigData requires re-thinking how you work on the Salesforce platform. Since you can assume that you're working with billions of records instead of thousands or even millions, common tasks like aggregate functions (e.g. Count()) or complex queries are difficult when you have only one index called a row key. However, the advantage working with BigData on the platform is that use cases involving billions of records are now achieveable for a variety of use cases including:

1. long term adoption metrics
2. audit
3. performance monitoring
4. archiving

As a result, it's better to think of BigData as a [data lake](https://en.wikipedia.org/wiki/Data_lake), where massive amounts of data can be processed asynchronously to meet any of the above use cases.

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/dataLake.png)

In the more concrete case of user login events which we now store in the Salesforce equivelent of BigData called a BigObject, it becomes important to understand how to work with the data at scale. This is especially important since not all capabilities that we've come to expect on the Salesforce platform, like operational reports or workflow, will be possible with a BigObject. It's a trade off for scale with limited platform capabilities.

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/LoginEvents.png)

For instance, rather than querying the BigObject using a convention like synchronous SOQL via the API for use in real-time applications, it's better to use a new convention called asynchronous SOQL which is now in pilot. 

[Asynchronous SOQL](http://docs.releasenotes.salesforce.com/en-us/winter16/release-notes/rn_general_async_query.htm) is similar to the Bulk API in the way it's job based. But instead of full CRUD capabilities primarily to work with the data off-platform, asynchronous SOQL provides query-and-insert capability to retreive sets of data and insert it into a structured object. Currently, this means moving data between BigObjects and custom objects on the platform.

For instance, you may want to create a subset or reduced set of data every hour, daily, or weekly in order to have the full transactionality of the Salesforce platform at your fingertips. With this design pattern, we can use scheduled and batch apex to migrate subsets of data from a BigObject into custom objects. For instance, the ability to extract last week's worth of LoginEvents in order to report on it.

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/timeline.png)

As a result, it's now possible to report on it using operational reports:

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/report.png)

or with Wave for advanced exploratory capabilities:

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/LoginForensics.png)


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

Because you are calling REST API from within Apex, you need to set Remote Site Settings:

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/remoteSite.png)

Based on your security policy, you should consider setting a session timeout longer than normal to ensure that the scheduled job's sessionId doesn't expire too quickly.

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/sessionSettings.png)

In order to scheduled your apex jobs to run, you can use Execute Anonymous Apex from the Developer Console:

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/executeAnon.png)

This will enable you to schedule Apex with more granularity than just using the UI in Setup.

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/scheduledApex.png)


Debugging is fairly limited; however, the code does parse the JSON results so that you can get the JobId that was created when the Asynchronous SOQL job is run:

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/debug.png)

This enables you to check the status via Workbench or the REST API:

![alt tag] (https://raw.github.com/atorman/asyncSOQL/master/img/jobId.png)

## Challenges using Async SOQL

Keep in mind, Asynchronous SOQL is still in pilot as is LoginForensics. So this is definitely bleeding edge. However, there are some challenges to be aware of in this design pattern:

1. Because the output is only to custom objects or BigObjects, you have to manage your own DML operations such as deleting records to ensure that you don't go over capacity.
2. BigObjects are still in pilot as well. As a result, I chose to use custom objects as the output for the query just to reduce the number of pilots this needed to interact with.
3. Because Async SOQL is accessed via the REST API, there were many considerations for calling it within Apex:
  1. I had to use Remote Site Settings to ensure that you can call out to that pod
  2. I had to use @future(callouts=true) in order to call Async SOQL from a scheduled Apex
  3. I had to pass the sessionId when I scheduled Apex via Execute Anonymous Apex which presented a problem where the session could expire. As a result, I'm refreshing the sessionId every hour which is less desireable than just running the scheduled Apex once per day. Here's the [Stackexchange post](http://salesforce.stackexchange.com/questions/21435/how-to-get-userinfo-getsessionid-in-scheduler-batch) that helped solve this one.
  4. I initially tried to delete the custom object records directly in scheduled apex only to hit every Apex limit known. As a result, I examined calling Bulk API from Apex but finally settled on calling batch apex from a scheduled job to get it done. 
4. Async SOQL debugging is still challenging. You get the jobId and can query it using the REST API; however, it's difficult to take action on this without callbacks.
5. Keep in mind if you change any scheduled Apex code, you will first need to delete the existing scheduled jobs within Setup > Scheduled Jobs before reloading them using Execute Anonymous Apex.

## Future design considerations

1. Using Apex to call REST API with Scheduled Apex was challenging; however, I wanted to first work on the Salesforce platform before utilizing apps on other platforms to do the same thing. The next iteration of this application would be to write an automated python job on Heroku using a worker dyno to make it a little easier than combining REST API with scheduled and batch Apex.
2. Instead of always overwriting the data, I would explore a differential design where I seed the data up front and then only trim or append a limited amount of data every hour. This would reduce some of the scale issues I encountered trying to delete and re-add everything everytime.

## Credit

Contributors include:

* Adam Torman created and orchestrated the majority of the repository
* Adam Purkiss provided expert consultation as my phone-a-friend
* Eli Levine who created Asynchronous SOQL

This repo is As-Is. All pull requests are welcome.