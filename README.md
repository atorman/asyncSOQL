## Async SOQL Sample



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



## Credit

Contributors include:

* Adam Torman created and orchestrated the majority of the repository
* Adam Purkiss provided expert consultation as my phone-a-friend
* 

This repo is As-Is. All pull requests are welcome.

## Screen Shot
![alt tag] (https://raw.github.com/atorman/apexLimitEvents/master/samplePage.png)