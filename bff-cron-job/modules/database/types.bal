// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/sql;
import ballerina/time;

# Database configuration.
# 
# + host - Database Host 
# + user - Database User  
# + password - Database Password
# + name - Database Name 
# + port - Database Port
public type DatabaseConfig record {
    string host;
    string user;
    string password;
    string name;
    int port;
};

# Booking database type
# 
# + bookingId - id of the booking  
# + date - date which the booking is made 
# + email - email of the user who made the booking 
# + preferences - json object with the meal preferences for the booking 
# + status - status of the booking (Booked, Upcoming)  
# + isActive - flag to identify whether the booking is active or not  
# + scheduleId - id of the schedule if it is added from a schedule
# + createdAt - date and time the booking is created
# + lastUpdatedAt - most recent date and time the booking is updated
public type Booking record {|
    @sql:Column {name: "booking_id"}
    int bookingId?;
    time:Date date;
    string email;
    json preferences;
    string status?;
    @sql:Column {name: "active"}
    boolean isActive?;
    @sql:Column {name: "created_at"}   
    time:Civil createdAt?;
    @sql:Column {name: "last_updated_at"}      
    time:Civil lastUpdatedAt?;
    @sql:Column {name: "schedule_id"}   
    int? scheduleId?;
|};

# Schedule database type
# 
# + scheduleId - id of the schedule 
# + email - email of the user who created the schedule  
# + scheduleName - name of the schedule 
# + recurringMode - recurring mode of the schedule  
# + isActive - flag to identify whether the schedule is active or not  
# + isDeleted - flag to identify whether the schedule is deleted or not  
# + preferences - json object with the meal preferences for all the days selected in thw schedule
# + createdAt - date and time the shedule is created
# + lastUpdatedAt - most recent date and time the schedule is updated 
public type Schedule record {|
    @sql:Column {name: "schedule_id"}   
    int scheduleId?;
    string email;
    @sql:Column {name: "schedule_name"}   
    string scheduleName;
    @sql:Column {name: "recurring_mode"}   
    string recurringMode;
    @sql:Column {name: "active"}   
    boolean isActive?;
    @sql:Column {name: "deleted"}   
    boolean isDeleted?;
    json preferences;
    @sql:Column {name: "created_at"}   
    time:Civil createdAt?;
    @sql:Column {name: "last_updated_at"}      
    time:Civil lastUpdatedAt?;
|};



