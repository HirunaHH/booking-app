// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/sql;
import wso2_office_booking_cron_job.utils;

# Query to delete the booking with a specific email and booking_id
# 
# + date - Date
# + return - sql parameterized query
function getTodaysBookingsQuery(string date) returns sql:ParameterizedQuery{
    return `
    SELECT
        booking_id, date, email, preferences, last_updated_at
    FROM
        booking
    WHERE
        date=${date}
        AND active=true
        AND status!=${utils:BOOKED}
    ORDER BY
        date DESC
    `;
}
