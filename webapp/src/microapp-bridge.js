const nativebridge = require('@nrk/nativebridge')


export function getToken(callback) {
    nativebridge.rpc({                          
        topic: 'token',
        data: {},
        resolve: (data) => {
          callback(data.data);
        }, 
        reject: (err) => {
          console.log(err);
          callback();
        }, 
        timeout: 3000
      });
};

export function showAlert(title, message, buttonText, successCallback, failedToRespondCallback) {
    nativebridge.rpc({                          
        topic: 'alert',
        data: {
            title: title,
            message: message,
            buttonText: buttonText
        },
        resolve: () => {
          successCallback();

        }, 
        reject: (err) => {
          failedToRespondCallback(err);
        }, 
        timeout: 120000
      });
};

export function showConfirmAlert(title, message, confirmButtonText, cancelButtonText, confirmCallback, cancelCallback, failedToRespondCallback) {
    nativebridge.rpc({                          
        topic: 'confirm-alert',
        data: {
            title: title,
            message: message,
            confirmButtonText: confirmButtonText,
            cancelButtonText: cancelButtonText
        },
        resolve: (data) => {
          if (data.action === 'confirm') {
            confirmCallback();
          } else if (data.action === 'cancel') {
            cancelCallback();
          } else {
            failedToRespondCallback();
          }
        }, 
        reject: (err) => {
          failedToRespondCallback(err);
        }, 
        timeout: 120000
      });
};


export function scanQRCode(successCallback, failedToRespondCallback) {
    nativebridge.rpc({                          
        topic: 'scan-qr-code',
        data: {},
        resolve: (data) => {
          successCallback(data.qrData);
        }, 
        reject: (err) => {
          failedToRespondCallback(err);
        }, 
        timeout: 120000
      });
};

export function saveLocalData(key, value, callback, failedToRespondCallback) {
  key = key.toString().replace(" ", "-").toLowerCase();
  var encodedValue = btoa(JSON.stringify(value));

  nativebridge.rpc({                          
    topic: 'save-local-data',
    data: {
      key: key,
      value : encodedValue
    },
    resolve: () => {
      callback();
    }, 
    reject: (err) => {
      failedToRespondCallback(err);
    }, 
    timeout: 5000
  });

};

export function getLocalData(key, callback, failedToRespondCallback) {
  key = key.toString().replace(" ", "-").toLowerCase();
  nativebridge.rpc({                          
    topic: 'get-local-data',
    data: {
      key: key
    },
    resolve: (encodedData) => {
      console.log("return encoded " + encodedData.value);
      var jsonObject = JSON.parse(atob(encodedData.value));
      console.log("json object" + jsonObject);
      callback(jsonObject);
    }, 
    reject: (err) => {
      failedToRespondCallback(err);
    }, 
    timeout: 5000
  });
};

export function totpQrMigrationData(callback, failedToRespondCallback) {
  nativebridge.rpc({                          
    topic: 'get-totp-qr-migration-data',
    data: {},
    resolve: (encodedData) => {
      var jsonObject = JSON.parse(btoa(encodedData));
      callback(jsonObject);
    }, 
    reject: (err) => {
      failedToRespondCallback(err);
    }, 
    timeout: 5000
  });
};

