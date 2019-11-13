//   Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

// Test file for Pet Store Sample Backend.

import ballerina/io;
import ballerina/test;
import ballerina/http;
import celleryio/cellery;
//import ballerina/runtime;

cellery:InstanceState[] instanceList = [];
string PET_BE_CONTROLLER_ENDPOINT = "";

# Handle creation of instances for running tests
@test:BeforeSuite
function setup() {
    cellery:ImageName iName = <cellery:ImageName>cellery:getCellImage();
    io:println(iName);

    cellery:InstanceState[]|error? result = run(iName, {}, true, true);
    io:println(result);
    if (result is error) {
        cellery:InstanceState iNameState = {
            iName : iName, 
            isRunning: true
        };
        instanceList[instanceList.length()] = <@untainted> iNameState;
    } else {
        instanceList = <cellery:InstanceState[]>result;
    }

    cellery:Reference petBeUrls = <cellery:Reference>cellery:getCellEndpoints(<@untainted> instanceList);
    PET_BE_CONTROLLER_ENDPOINT= <string>petBeUrls["controller_ingress_api_url"];
}

@test:Config {}
function testDocker() {
    map<cellery:Env> envVars = {PET_BE_CELL_URL: { value: PET_BE_CONTROLLER_ENDPOINT }};
    error? a = cellery:runDockerTest("docker.io/wso2cellery/pet-be-tests", envVars);
}

# Tests inserting order from an external cell by calling the pet-be gateway
@test:Config {}
function testInsertOrder() {
    
    // string PET_BE_CONTROLLER_ENDPOINT = "http://pet-be--gateway-service:80/controller/orders";
    io:println(PET_BE_CONTROLLER_ENDPOINT);

    string ordersContext = "/orders";
    string payload = "{\"order\":[{\"id\":1,\"amount\":1}]}";
    string expectedPostResponsePrefix = "status=SUCCESS";
    string expectedGetResponse = "{\"status\":\"SUCCESS\",\"data\":{\"orders\":[{\"order\":[{\"item\":{\"id\":1," +
                "\"name\":\"Pet Travel Carrier Cage\",\"description\":\"Ideal for airline travel, the carry cage has " +
                "a sturdy handle grip and tie down strapping points for safe and secure travel\"";
    
    http:Client clientEndpoint = new(PET_BE_CONTROLLER_ENDPOINT);
    http:Request req = new;
    req.setHeader("Content-Type", "application/json");
    req.setPayload(payload);
    var response = clientEndpoint->post(ordersContext, req);

    io:print(response);
    io:println();
    string responseStr = handleResponse(response);
    test:assertTrue(
        responseStr.startsWith(expectedPostResponsePrefix), 
        msg = "Order insertion failed.\n Expected: \n" + expectedPostResponsePrefix + "\n Actual: \n" + responseStr
    );
}

function handleResponse(http:Response|error response) returns @tainted string {
    if (response is http:Response) {
        var msg = response.getJsonPayload();
        if (msg is json) {
            return msg.toString();
        } else {
            return "Invalid payload received:" + msg.reason();
        }
    } else {
        return "Error when calling the backend: " + response.reason();
    }
}

# Handle deletion of instances for running tests
@test:AfterSuite
public function cleanUp() {
    error? err = cellery:stopInstances(instanceList);
}
