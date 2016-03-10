///////// Application Code ///////////

// VARIABLES
agentID <- split(http.agenturl(), "/").pop();

// APPLICATION FUNCTIONS

// save settings to local storage
function saveSettings(settings) {
    server.save({ "settings" : settings });
}

// check local storage for settings and sync with device
function getSettings(dummy) {
    local persist = server.load();

    // if no settings request from device
    if (!("settings" in persist)) { device.send("getDeviceSettings", null); }
    
    // if have settings send to device
    if ("settings" in persist) { device.send("agentSettings", persist.settings); }
}

// overwrite default reading/reporting interval
// settings is a table 
function updateSettings(settings) {
    local persist = server.load();
    if ("settings" in persist) {
        if ( !("readingInt" in settings) ) {
            settings.readingInt <- persist.settings.readingInt;
        }
        if ( !("reportingInt" in settings) ) {
            settings.reportingInt <- persist.settings.reportingInt;
        }
    }
    saveSettings(settings);
    device.send("agentSettings", settings);
}

local sensorData = {
  "tempSensor" : {},
  "tempHumidSensor" : {},
  "ambLightSensor" : {},
  "accelerometerSensor" : {},
  "pressureSensor" : {},
  "magnetometerSensor" : {}
};

// Store latest data to local variable
function storeData(data) {
    foreach(sensor, readings in data) {
        readings.sort( function (a, b) { return b.ts <=> a.ts });
        local reading = readings.pop();
        server.log(sensor + " " + http.jsonencode(reading));
        sensorData[sensor] = reading;
    }
    device.send("ack", "OK");
}

// DEVICE LISTENERS
device.on("deviceSettings", saveSettings);
device.on("getAgentSettings", getSettings);
device.on("data", storeData);

// // Uncomment if you want to update reading and/or reporting intervals
// local newSettings = {"reportingInt" : 600};
// updateSettings(newSettings);

function requestHandler(request, response) {
  local err = 0;
  try {
    switch(request.path) {
      case "/sensors/accelerometer":
        response.send(200, http.jsonencode(sensorData["accelerometerSensor"]));
        break;
      case "/sensors/ambient-light":
        response.send(200, http.jsonencode(sensorData["ambLightSensor"]));
        break;
      case "/sensors/magnetometer":
        response.send(200, http.jsonencode(sensorData["magnetometerSensor"]));
        break;
      case "/sensors/pressure":
        response.send(200, http.jsonencode(sensorData["pressureSensor"]));
        break;
      case "/sensors/temperature":
        response.send(200, http.jsonencode(sensorData["tempSensor"]));
        break;
      case "/sensors/temperature-humidity":
        response.send(200, http.jsonencode(sensorData["tempHumidSensor"]));              
        break;
      default:
        response.send(404, ("Not Found"));
        break;
    };
  } catch(ex) {
    response.send(500, ("Agent error: " + ex))
  }
};
http.onrequest(requestHandler);