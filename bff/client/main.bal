// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/task;
import ballerina/log;
import wso2_office_booking.utils;
import wso2_office_booking.database;
import ballerinax/googleapis.sheets as sheets;
import wso2_office_booking.types;

configurable readonly & types:OAuthConfigData oAuthConfigData = ?;
configurable readonly & types:SpreadsheetConfigDara spreadsheetConfigData = ?;

class Job{
    *task:Job;
    sheets:Client? spreadsheetClient=null;
    sheets:Spreadsheet? spreadsheet=null;
    sheets:Sheet? sheet=null;


    public function init(){
        sheets:Client|error spreadsheetClient = self.createConnector();
        if spreadsheetClient is sheets:Client{
            self.spreadsheetClient = spreadsheetClient;

            sheets:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetByUrl(spreadsheetConfigData.spreadsheetUrl);

            if (spreadsheet is sheets:Spreadsheet) {
                self.spreadsheet = spreadsheet;

                sheets:Sheet|error sheet = spreadsheetClient->getSheetByName(spreadsheet.spreadsheetId,spreadsheetConfigData.sheetName);
                if sheet is sheets:Sheet{
                    self.sheet = sheet;
                    log:printInfo("Connection to google sheet "+ spreadsheetConfigData.sheetName + " successfull");
                }else{
                    log:printError("Error retrieving sheet : " + spreadsheetConfigData.sheetName);
                }
            } else {
                log:printError("Error retrieving spreadsheet");
            }
        } else{
            log:printError("Error generating sheets client");
        }
    }

    public function execute(){
        database:Booking[]|error bookingList = database:getTodaysBookings();
        if bookingList is error{
            log:printError("Could not retrieve booking details");
        } else{
            sheets:Client? spreadsheetClient = self.spreadsheetClient;
            sheets:Spreadsheet? spreadsheet = self.spreadsheet;
            sheets:Sheet? sheet = self.sheet;

            if(spreadsheet is sheets:Spreadsheet && sheet is sheets:Sheet && spreadsheetClient is sheets:Client){

                error? writeResHeaders = self.writeToSheet(spreadsheetClient,spreadsheet,sheet,"A1:D1", [spreadsheetConfigData.tableHeaders]);
                if writeResHeaders is (){
                    string[][] bookingDetails = self.getBookingDetails(bookingList);
                    error? writeResDetails=  self.writeToSheet(spreadsheetClient, spreadsheet, sheet, self.getRange(bookingDetails.length()), bookingDetails);
                    if writeResDetails is (){
                        log:printInfo("Bookings successfully recorded to the google sheet");
                    }else{
                        log:printError("Could not record bookings");
                    }
                }else{
                    log:printError("Could not record bookings");
                }
            }
        }
    }

    public function createConnector() returns sheets:Client|error{
        sheets:ConnectionConfig spreadsheetConfig = {
            auth: {
                clientId: oAuthConfigData.clientId,
                clientSecret: oAuthConfigData.clientSecret,
                refreshUrl: sheets:REFRESH_URL,
                refreshToken: oAuthConfigData.refreshToken
            }
        };

        sheets:Client spreadsheetClient = check new (spreadsheetConfig);
        return spreadsheetClient;
    }


    public function writeToSheet(sheets:Client spreadsheetClient, sheets:Spreadsheet spreadsheet, sheets:Sheet sheet, string rangeStr, string[][] values) returns error?{
        sheets:Range range = {a1Notation: rangeStr, values: values};
        error? spreadsheetRes = spreadsheetClient->setRange(spreadsheet.spreadsheetId, sheet.properties.title, range);
        return spreadsheetRes;
    }

    public function getRange(int rows) returns string{
        return "A2:D" + (rows+1).toString();
    }

    public function getBookingDetails(database:Booking[] bookings) returns string[][]{
        string[][] bookingDetails = [];
        int i=0;
        bookings.forEach(function(database:Booking booking){
            json|error lunchPreference = booking.preferences.Lunch;
            string[] tempArray = [utils:civilToGoogleTimestampString(booking.lastUpdatedAt), booking.email, utils:dateToDateString(booking.date), lunchPreference is error?"":lunchPreference.toString()];
            bookingDetails[i] = tempArray;
            i+=1;
        });
        return bookingDetails;
    }

}
public function main() returns error?{
    task:JobId _ = check task:scheduleJobRecurByFrequency(new Job(), 30);
}