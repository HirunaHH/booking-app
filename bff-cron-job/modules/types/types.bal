// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

# OAuth Credentials 
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
