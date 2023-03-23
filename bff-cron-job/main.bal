// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/log;
import wso2_office_booking_cron_job.utils;
import wso2_office_booking_cron_job.database;
import ballerinax/googleapis.sheets as sheets;
import wso2_office_booking_cron_job.types;

// configurable values
configurable readonly & types:OAuthConfigData oAuthConfigData = ?;
configurable readonly & types:SpreadsheetConfigDara spreadsheetConfigData = ?;

class GoogleSheetHandler {
    sheets:Client spreadsheetClient;
    sheets:Spreadsheet spreadsheet;
    sheets:Sheet sheet;

    # init function 
    #
    # + spreadsheetClient - spreadsheetClient created from OAuth token values
    # + spreadsheet - spreadsheet created by the given spreadsheet URL
    # + sheet - sheet object created using given worksheet name
    public function init(sheets:Client spreadsheetClient, sheets:Spreadsheet spreadsheet, sheets:Sheet sheet) {
        self.spreadsheetClient = spreadsheetClient;
        self.spreadsheet = spreadsheet;
        self.sheet = sheet;
    }

    # Record active bookings made for the current date
    #
    public function recordBookings() {
        database:Booking[]|error bookingList = database:getTodaysBookings();
        if bookingList is error {
            log:printError("Could not retrieve booking details");
            return;
        }

        if (self.clearSheet() is error) {
            log:printError("Could not record bookings");
            return;
        }

        error? writeResHeaders = self.writeToSheet(self.getRange(1, spreadsheetConfigData.tableHeaders.length(), "A1"), [spreadsheetConfigData.tableHeaders]);
        if writeResHeaders is () {
            string[][] bookingDetails = self.getBookingDetails(bookingList);
            error? writeResDetails = self.writeToSheet(self.getRange(bookingDetails.length(), spreadsheetConfigData.tableHeaders.length(), "A2"), bookingDetails);
            if writeResDetails is () {
                log:printInfo("Bookings successfully recorded to the google sheet");
                return;
            }
        }
        log:printError("Could not record bookings");
    }

    # Write given values to the worksheet in the given range
    #
    # + rangeStr - range
    # + values - 2D string array with values to be written
    # + return - error or ()
    public function writeToSheet(string rangeStr, string[][] values) returns error? {
        sheets:Range range = {a1Notation: rangeStr, values: values};
        error? spreadsheetRes = self.spreadsheetClient->setRange(self.spreadsheet.spreadsheetId, self.sheet.properties.title, range);
        return spreadsheetRes;
    }

    # Clear the sheet
    #
    # + return - error or ()
    public function clearSheet() returns error? {
        error? clearAllResult = check self.spreadsheetClient->clearAllBySheetName(self.spreadsheet.spreadsheetId, spreadsheetConfigData.sheetName);
        return clearAllResult;
    }

    # Get range in the google sheet which can accomodate the given no of rows and columns, starting from the given cell
    #
    # + rows - no of rows
    # + columns - no of columns
    # + startingCell - starting cell of the range
    # + return - range string
    public function getRange(int rows, int columns, string startingCell) returns string {
        string|error endingColumn = string:fromCodePointInt(startingCell[0].toCodePointInt() + columns - 1);
        if endingColumn is error {
            return "";
        }
        int|error startingRow = (int:fromString(startingCell.substring(1)));
        if startingRow is error {
            return "";
        }
        int endingRow = startingRow + rows - 1;
        return startingCell + ":" + endingColumn + endingRow.toString();
    }

    # Get an array with consisting of only details of the bookings that are needed to be written to the google sheet
    #
    # + bookings - array of Booking objects 
    # + return - 2D string array consisting of required details of the bookings
    public function getBookingDetails(database:Booking[] bookings) returns string[][] {
        string[][] bookingDetails = [];
        int i = 0;
        bookings.forEach(function(database:Booking booking) {
            json|error lunchPreference = booking.preferences.Lunch;
            string[] tempArray = [utils:civilToGoogleTimestampString(booking.lastUpdatedAt), booking.email, utils:dateToDateString(booking.date), lunchPreference is error ? "" : lunchPreference.toString()];
            bookingDetails[i] = tempArray;
            i += 1;
        });
        return bookingDetails;
    }

}

# Create the google sheet api connector using the given configurable values
#
# + return - Return Value Description
public function createConnector() returns sheets:Client? {
    sheets:ConnectionConfig spreadsheetConfig = {
        auth: {
            clientId: oAuthConfigData.clientId,
            clientSecret: oAuthConfigData.clientSecret,
            refreshUrl: sheets:REFRESH_URL,
            refreshToken: oAuthConfigData.refreshToken
        }
    };

    sheets:Client|error spreadsheetClient = new (spreadsheetConfig);
    if spreadsheetClient is error {
        return ();
    }
    return spreadsheetClient;
}

public function main() {

    sheets:Client? spreadsheetClient = createConnector();
    if spreadsheetClient is () {
        log:printError("Error generating sheets client");
        return;
    }

    sheets:Spreadsheet|error spreadsheet = spreadsheetClient->openSpreadsheetByUrl(spreadsheetConfigData.spreadsheetUrl);
    if spreadsheet is error {
        log:printError("Error retrieving spreadsheet");
        return;
    }

    sheets:Sheet|error sheet = spreadsheetClient->getSheetByName(spreadsheet.spreadsheetId, spreadsheetConfigData.sheetName);
    if sheet is error {
        log:printError("Error retrieving sheet : " + spreadsheetConfigData.sheetName);
        return;
    }
    log:printInfo("Connection to google sheet " + spreadsheetConfigData.sheetName + " successfull");

    GoogleSheetHandler googleSheetHandler = new GoogleSheetHandler(spreadsheetClient, spreadsheet, sheet);
    googleSheetHandler.recordBookings();
}
