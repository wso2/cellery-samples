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

// Cell file for Pet Store Sample Backend.
// This Cell encompasses the components which deals with the business logic of the Pet Store

import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    string isGuestMode = "true";

    cellery:Component portalComponent = {
            name: "portal",
            src: {
                image: "wso2cellery/samples-pet-store-portal:latest-dev"
            },
            ingresses: {
                portal: <cellery:HttpPortIngress>{
                    port: 80
              }
            },
            envVars: {
                PET_STORE_CELL_URL: { value: ""},
                PORTAL_PORT: { value: 80 },
                BASE_PATH: { value: "." },
                GUEST_MODE_ENABLED: {value: isGuestMode}

            },
            dependencies: {
                composites: {
                    petStoreBackend: <cellery:ImageName>{ org: "wso2cellery", name: "pet-be-guest-mode-composite", ver: "latest-dev" }
                }
        }
    };

    // Assign the URL of the backend cell
   cellery:Reference petStoreBackend = cellery:getReference(portalComponent, "petStoreBackend");
   portalComponent["envVars"]["PET_STORE_CELL_URL"].value =
        "http://" +<string>petStoreBackend["controller_host"] + ":" + <string>petStoreBackend["controller_port"];


    // Composite Initialization
    cellery:Composite petstore = {
        components: {
            portal: portalComponent
        }
    };

    return <@untainted> cellery:createImage(petstore,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies)
       returns (cellery:InstanceState[]|error?) {
    cellery:Composite petFE = check cellery:constructImage( iName);
    return <@untainted> cellery:createInstance(petFE, iName, instances, startDependencies, shareDependencies);
}