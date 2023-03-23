// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/time;
import wso2_office_booking_cron_job.utils;

configurable readonly & DatabaseConfig databaseConfig = ?;

// create the database client with configureable credentials
final mysql:Client dbClient = check new (
    host = databaseConfig.host, user = databaseConfig.user, password = databaseConfig.password, port = databaseConfig.port, database = databaseConfig.name
);

# Get the active booking list on current date
# 
# + return - active booking list with the date matching to current date or error
public function getTodaysBookings() returns Booking[]|error {
    time:Civil today = time:utcToCivil(time:utcNow());
    string date = utils:dateToDateString(today);
    Booking[] bookings = [];
    stream<Booking, error?> resultStream = dbClient->query(getTodaysBookingsQuery(date));
    _ = check resultStream.forEach(function(Booking booking) {
        bookings.push(booking);
    });

    check resultStream.close();
    return bookings;
}


