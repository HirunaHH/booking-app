// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/time;

// Date & Time Helper Functions

# Convert a Date type variable to string with the format of "YYYY-MM-DD"
#
# + date - Date object
# + return - formatted DateString
public function dateToDateString(time:Date date) returns string {
    record {|string year; string month; string day;|} strDateRecord = {
        year: date.year.toString(),
        month: date.month.toString(),
        day: date.day.toString()
    };

    if date.month < 10 {
        strDateRecord.month = "0" + date.month.toString();
    }

    if date.day < 10 {
        strDateRecord.day = "0" + date.day.toString();
    }

    return strDateRecord.year + "-" + strDateRecord.month + "-" + strDateRecord.day;
}

# Convert a Date to a string
#
# + date - Date
# + return - date string or error
public function dateToDateTimeString(time:Date date) returns string {
    return dateToDateString(date) + DEFAULT_TIME_STRING_SUFFIX;
}

# Convert a Date to Utc
#
# + date - Date
# + return - Utc value or error
public function dateToUtc(time:Date date) returns time:Utc|error {
    string dateStr = dateToDateTimeString(date);
    return time:utcFromString(dateStr);
}

# Convert a Date to Civil value
#
# + date - Date
# + return - Civil value or error
public function dateToCivil(time:Date date) returns time:Civil|error {
    string dateStr = dateToDateTimeString(date);
    return time:civilFromString(dateStr);
}

# Convert a Civil value to a string in the format of "MM/DD/YYYY HH:MM:SS"
#
# + civil - Civil value
# + return - date-time string
public function civilToGoogleTimestampString(time:Civil? civil) returns string {
    string dateStr = civil?.month.toString() + "/" + civil?.day.toString() + "/" + civil?.year.toString();
    string timeStr = civil?.hour.toString() + ":" + civil?.minute.toString() + ":" + civil?.second.toString();
    return dateStr + " " + timeStr;
}

