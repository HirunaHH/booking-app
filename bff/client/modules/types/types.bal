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
public type OfficeBookingAppError record {|
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
public type OfficeBookingAppNotFoundError record {|
    *http:NotFound;
    OfficeBookingAppError body;
|};

# 500 Internal Server Error response 
# 
# + body - error message
public type OfficeBookingAppServerError record {|
    *http:InternalServerError;
    OfficeBookingAppError body;
|};

# 200 OK response 
# 
# + body - payload with success details
public type OfficeBookingAppSuccess record {|
    *http:Ok;
    DbOperationSuccessResult body;
|};

# 400 Bad Request Error response
# 
# + body - error message
public type OfficeBookingAppBadRequestError record{|
    *http:BadRequest;
    OfficeBookingAppError body;
|};
 