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

string PET_BE_CONTROLLER_ENDPOINT = "";

# Handle creation of instances for running tests
@test:BeforeSuite
function setup() {
    cellery:TestConfig testConfig = <@untainted>cellery:getTestConfig();
    cellery:runInstances(testConfig);
    
    cellery:Reference petBeUrls = <cellery:Reference>cellery:getInstanceEndpoints();
    PET_BE_CONTROLLER_ENDPOINT= <string>petBeUrls["controller_ingress_api_url"];
}

@test:Config {}
function testDocker() {
    map<cellery:Env> envVars = {PET_BE_CELL_URL: { value: PET_BE_CONTROLLER_ENDPOINT }};
    error? err = cellery:runDockerTest("docker.io/wso2cellery/samples-pet-store-order-tests", envVars);
    test:assertFalse(err is error, msg = "Docker image test failed.\n Reason: \n" + err.toString() + "\n");
}

# Tests inserting order from an external cell by calling the pet-be gateway
@test:Config {}
function testInsertOrder() {
    io:println(PET_BE_CONTROLLER_ENDPOINT);

    string ordersContext = "/orders";
    string payload = "{\"order\":[{\"id\":1,\"amount\":1}]}";
    string expectedPostResponsePrefix = "status=SUCCESS";
    
    http:Client clientEndpoint = new(PET_BE_CONTROLLER_ENDPOINT);
    http:Request req = new;
    req.setPayload(payload);
    req.setHeader("Content-Type", "application/json");
    var response = clientEndpoint->post(ordersContext, req);

    string responseStr = handleResponse(response);
    test:assertTrue(
        responseStr.startsWith(expectedPostResponsePrefix), 
        msg = "Order insertion failed.\n Expected: \n" + expectedPostResponsePrefix + "\n Actual: \n" + responseStr + "\n"
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
    error? err = cellery:stopInstances();
}
