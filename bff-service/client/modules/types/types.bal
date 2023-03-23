// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/http;

# OAuth Credentials and 
# 
# + clientId - OAuth Client ID
# + clientSecret - OAuth Client Secret  
# + refreshToken - Refresh Token 
# + accessToken - Access Token 
public type OAuthConfigData record {|
    string clientId;
    string clientSecret;
    string refreshToken;
    string accessToken;
|};

# Spreadhseet Configuration
# 
# + spreadsheetUrl - URL to the spreadsheet  
# + sheetName - worksheet name
# + tableHeaders - Headers of the worksheet
public type SpreadsheetConfigDara record {|
    string spreadsheetUrl;
    string sheetName;
    string[] tableHeaders;
|};

# Error with a message
# 
# + message - error message
public type AppError record {|
    string message;
|};

# Result retrieved after a successfull database operation
# 
# + affectedRowCount - Rows affected by the operation  
# + lastInsertId - Inserted id by the operation
public type DbOperationSuccessResult record {|
    int? affectedRowCount;
    string|int? lastInsertId?;
|};

//Types defining different response types

# 404 Not Found response 
# 
# + body - error message
public type AppNotFoundError record {|
    *http:NotFound;
    AppError body;
|};

# 500 Internal server error response 
# 
# + body - error message
public type AppServerError record {|
    *http:InternalServerError;
    AppError body;
|};

# 200 OK response 
# 
# + body - payload with success details
public type AppSuccess record {|
    *http:Ok;
    DbOperationSuccessResult body;
|};

# 400 Bad Request Error response
# 
# + body - error message
public type AppBadRequestError record{|
    *http:BadRequest;
    AppError body;
|};
 
# The preferences for a week
#
# + monday - preference for monday  
# + tuesday - preference for tuesday
# + wednesday - preference for wednesday  
# + thursday - preference for thursday  
# + friday - preference for friday
public type WeeklyPreferences record {|
    DayPreference monday?;
    DayPreference tuesday?;
    DayPreference wednesday?;
    DayPreference thursday?;
    DayPreference friday?;
|};

# The preference for a day
# 
# + lunch - lunch preference
# + breakfast - breakfast preference
public type DayPreference record {|
    string lunch?;
    string breakfast?;
|};