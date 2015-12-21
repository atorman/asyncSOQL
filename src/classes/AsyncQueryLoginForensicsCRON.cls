/**
 * Copyright (c) 2012, Salesforce.com, Inc.  All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 * 
 *   * Neither the name of Salesforce.com nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
global class AsyncQueryLoginForensicsCRON Implements Schedulable
    {
        private String sessionId;
        
        // schedule CRON to execute 15 min after the hour via Execute Anonymous Apex 
        // b/c session is renewed every hour, it shouldn't expire; however, you may need
        // to reschedule the job if it does expire.
        
        // System.schedule('AsyncQueryLoginForensicsCRON', '0 10 1-23 * * ?', new AsyncQueryLoginForensicsCRON(UserInfo.getSessionId()));
		
        // Set the sessionId passed in from Exec Anonymous Apex when the job starts
        global AsyncQueryLoginForensicsCRON( String sessionId ) {
            this.sessionId = sessionId;
        }
        
        global void execute(SchedulableContext sc) {
            queryLoginForensics(sessionId);
        }
        
        // annotate with @future(callout=true) since this is scheduled Apex in order
        // to make the necessary call out to the Rest API
        @future(callout=true)
        public static void queryLoginForensics(String sessionId){
        
        // set the session id passed in to a local variable
        String sId = sessionId;
        
        // set date range for last week or (-7) days
        DateTime f = datetime.now();
        String endTime = f.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
        System.debug('endTime:'+ endTime);
        DateTime s = f.addDays(-7);
        String startTime = s.format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\'');
        System.debug('startTime:'+ startTime);
        
        // primary: if there are records, don't execute the Async Query job
        // secondary: renew sessionId expiration time
        integer i = [SELECT Count() FROM Login__c];
        System.debug('There are this many Login custom object records: ' + i);
        
        if(i>0) {
            System.Debug('There are records so don\'t do anything.');
        } else {
            
            // Async SOQL JSON Body for post
            String content = '{"query":"SELECT AdditionalInfo,ApiType,ApiVersion,Application,Browser,ClientVersion,EventDate,Id,LoginHistoryId,LoginUrl,Platform,SourceIp,Status,UserId,Username FROM LoginEvent where EventDate >= ' +startTime+ ' AND EventDate <= ' +endTime+ '","targetObject":"Login__c","targetFieldMap":{"AdditionalInfo":"AdditionalInfo__c", "Username":"Username__c", "EventDate":"EventDate__c", "ApiType":"ApiType__c","ApiVersion":"ApiVersion__c","Application":"Application__c","Browser":"Browser__c","ClientVersion":"ClientVersion__c","Id":"Id__c","LoginHistoryId":"LoginHistoryId__c","LoginUrl":"LoginUrl__c","Platform":"Platform__c","SourceIp":"SourceIp__c","Status":"Status__c","UserId":"User__c"}}';
            
            //System.debug('content = ' + content);
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            // based on remote setting in setup for gs0 pod: /0rp
            req.setEndpoint('https://gs0.salesforce.com/services/data/v36.0/async-queries');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setBody(content);
            
            // Grab session Id that was passed in to authenticate
            req.setHeader('Authorization', 'Bearer ' + sId);
            
            // try callout to Async SOQL Rest API
            try {
                res = http.send(req);
                System.debug('request: '+ req.toString());
                System.debug('response: '+ res.toString());
                
                // parse JSON results to extract the jobid for tracking purposes
                JSONParser parser = JSON.createParser(res.getBody());  
                while (parser.nextToken() != null) {  
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String fieldName = parser.getText();
                        parser.nextToken();
                        if (fieldName == 'jobId') {
                            //accesstoken = parser.getText();
                            system.debug('jobId Text() => ' + parser.getText());
                        }
                    }
                }     
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            }
        }
    }  
  }