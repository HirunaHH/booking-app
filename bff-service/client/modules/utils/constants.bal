// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

public const DEFAULT_TIME_STRING_SUFFIX = "T00:00:00Z";

public enum Status {
    BOOKED = "Booked",
    UPDOMING = "Upcoming"
}

public const ADD_BOOKING_CUTOFF_HOUR = 9;
public const SHOW_BOOKINGS_CUTOFF_HOUR = 15;

// Date validate strings
public enum DateValidateErrorMessages{
    PREVIOUS_DATE = "Cannot add a booking for a previous date",
    INVALID_DATE = "Invalid date",
    TODAY_NOT_ALLOWED = "A booking cannot be made for today at this time",
    WEEKEND_DATE = "Cannot add bookings for weekends"
}

public const INTERNAL_ERROR = "Internal error occured";

public enum DefaultErrorMessages{
    ID_NOT_FOUND="Cannot find ID",
    CANNOT_RETRIEVE_FROM_DB="Could not retrieve details from the database",
    CANNOT_ADD_ENTRY="Could not add new entry",
    CANNOT_EDIT_ENTRY="Could not edit the entry",
    CANNOT_DELETE_ENTRY="Could not delete the entry",
    NAME_ALREADY_EXISTS="An entry exists for the given name",
    DATE_ALREADY_EXISTS="An entry exists for the given date",
    CANNOT_EDIT_ACTIVE_SCHEDULE="Cannot edit an active schedule. Please deactivate before editing",
    SCHEDULE_ALREADY_ACTIVE="Schedule is already active",
    CANNOT_EDIT_CONFIRMED_BOOKING="Cannot edit an already confirmed booking",
    NOT_MORE_THAN_3_SCHEDULES="Cannot save more than 3 schedules at a time. Try deleting a schedule before adding new one",
    PREFERENCE_EMPTY="Preferences cannot be empty",
    DATABASE_ERROR="Database error"
}

public final string[] & readonly DAYS_OF_WEEK = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "Saturday"];
public final map<int> & readonly RECURRING_WEEKS = {
    "1 week":1,
    "2 weeks":2,
    "3 weeks":3,
    "4 weeks":4
}; 

public enum Days{
    Monday="monday",
    Tuesday="tuesday",
    Wednesday="wednesday",
    Thursday="thursday",
    Friday="friday"
}

public enum AvailableMeals{
    Lunch="Lunch"
}
