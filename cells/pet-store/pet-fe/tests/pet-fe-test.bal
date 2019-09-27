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

// Test file for Pet Store Sample Frontend.
// TODO: This constains a testcases written for pet backend and to test the flow and needs
// to be updated with a test case for the pet frontend.

import ballerina/io;
import ballerina/test;
import ballerina/config;
import ballerina/http;
import celleryio/cellery;

cellery:InstanceState[] instanceList = [];

# Handle creation of instances for running tests
@test:BeforeSuite
function setup() {
    cellery:ImageName iName = <cellery:ImageName>cellery:getCellImage();
    map<cellery:ImageName> instances = <map<cellery:ImageName>>cellery:getDependencies();

    cellery:InstanceState[]|error? result = run(iName, instances, true, false);
    if (result is error) {
        cellery:InstanceState iNameState = {
            iName : iName, 
            isRunning: true
        };
        instanceList[instanceList.length()] = iNameState;

        foreach var(key,value) in instances {
            cellery:InstanceState dependencyState = {
                iName: value,
                isRunning: true ,
                alias: key
            };
            instanceList[instanceList.length()] = dependencyState;
        }
    } else {
        instanceList = <cellery:InstanceState[]>result;
    }
}

# # Tests inserting order from an external cell by calling the pet-be gateway
@test:Config
function testInsertOrder() {
    cellery:Reference petBeUrls = <cellery:Reference>cellery:getGatewayHost(instanceList, alias = "petStoreBackend");
    cellery:Reference petFeUrls = <cellery:Reference>cellery:getGatewayHost(instanceList);
    
    string PET_FE_GATEWAY_ENDPOINT = "http://" + <string>petFeUrls.gateway_host;
    string PET_BE_CONTROLLER_ENDPOINT= <string>petBeUrls.controller_ingress_api_url;
    io:println(PET_FE_GATEWAY_ENDPOINT);
    io:println(PET_BE_CONTROLLER_ENDPOINT);

    string ordersContext = "/orders";
    string payload = "{\"order\":[{\"id\":1,\"amount\":1}]}";
    string expectedPostResponsePrefix = "{\"status\":\"SUCCESS\", \"data\":{\"id\":";
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
        responseStr.hasPrefix(expectedPostResponsePrefix), 
        msg = "Order insertion failed.\n Expected: \n" + expectedPostResponsePrefix + "\n Actual: \n" + responseStr
    );
}

function handleResponse(http:Response|error response) returns string {
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
