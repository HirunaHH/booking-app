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
public const DATE_OK = "Date is okay";
public const PREVIOUS_DATE = "Previous date";
public const INVALID_DATE = "Invalid date";
public const TODAY_NOT_ALLOWED = "Not allowed for today";
public const WEEKEND_DATE = "Weekend date";

public const INTERNAL_ERROR = "Internal error occured";

