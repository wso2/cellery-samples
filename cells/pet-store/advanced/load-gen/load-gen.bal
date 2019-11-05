//
//  Copyright (c) 2019 WSO2 Inc. (http:www.wso2.org) All Rights Reserved.
//
//  WSO2 Inc. licenses this file to you under the Apache License,
//  Version 2.0 (the "License"); you may not use this file except
//  in compliance with the License.
//  You may obtain a copy of the License at
//
//  http:www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

import celleryio/cellery;
import ballerina/config;

public function build(cellery:ImageName iName) returns error? {
    cellery:Component loadGenComponent = {
        name: "load-gen",
         src: {
            image: "wso2cellery/samples-pet-store-load-gen:latest-dev"
        },
        envVars: {
            DURATION: { value: "5m" },
            CONCURRENCY: {value: "40"},
            PET_STORE_INST: {value: "pet-be"}
        }
    };

    cellery:CellImage loadGenCell = {
        components: {
            loadGen: loadGenComponent
        }
    };
    return <@untainted> cellery:createImage(loadGenCell,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage loadGenImage = check cellery:constructCellImage( iName);
    cellery:Component loadGenComponent = <cellery:Component> loadGenImage.components["loadGen"];

    string duration = config:getAsString("DURATION");
    if (duration !== "") {
        loadGenComponent["envVars"]["DURATION"].value = duration;
    }

    string concurrency = config:getAsString("CONCURRENCY");
    if (concurrency !== "") {
            loadGenComponent["envVars"]["CONCURRENCY"].value = concurrency;
    }

    string petStoreInstance = config:getAsString("PET_STORE_INST");
    if (petStoreInstance !== "") {
            loadGenComponent["envVars"]["PET_STORE_INST"].value = petStoreInstance;
    }
    return <@untainted> cellery:createInstance(loadGenImage, iName, instances, startDependencies, shareDependencies);
}

