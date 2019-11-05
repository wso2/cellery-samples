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

// Cell file for Pet Store Sample Frontend.
// This Cell encompasses the component which exposes the Pet Store portal

import celleryio/cellery;
import ballerina/config;

public function build(cellery:ImageName iName) returns error? {
    // Portal Component
    // This is the Component which exposes the Pet Store portal
    cellery:Component portalComponent = {
        name: "portal",
        src: {
            image: "wso2cellery/samples-pet-store-portal:latest-dev"
        },
        ingresses: {
            portal: <cellery:WebIngress>{ // Web ingress will be always exposed globally.
                port: 80,
                gatewayConfig: {
                    vhost: "pet-store.com",
                    context: "/",
                    oidc: {
                        nonSecurePaths: ["/", "/app/*"],
                        providerUrl: "",
                        clientId: "",
                        clientSecret: {
                            dcrUser: "",
                            dcrPassword: ""
                        },
                        redirectUrl: "http://pet-store.com/_auth/callback",
                        baseUrl: "http://pet-store.com/",
                        subjectClaim: "given_name"
                    }
                }
            }
        },
        envVars: {
            PET_STORE_CELL_URL: { value: "" },
            PORTAL_PORT: { value: 80 },
            BASE_PATH: { value: "." }
        },
        dependencies: {
            composites: {
                petStoreBackend: <cellery:ImageName>{ org: "wso2cellery", name: "pet-be-composite", ver: "latest-dev" }
            }
        }
    };

    // Assign the URL of the backend cell
   cellery:Reference petStoreBackend = cellery:getReference(portalComponent, "petStoreBackend");
   portalComponent["envVars"]["PET_STORE_CELL_URL"].value =
   "http://" +<string>petStoreBackend["controller_host"] + ":" + <string>petStoreBackend["controller_port"];

    // Cell Initialization
    cellery:CellImage petStoreFrontendCell = {
        components: {
            portal: portalComponent
        }
    };
    return <@untainted> cellery:createImage(petStoreFrontendCell,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies,
       boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage petStoreFrontendCell = check cellery:constructCellImage( iName);
    cellery:Component portalComponent = <cellery:Component> petStoreFrontendCell.components["portal"];
    string vhostName = config:getAsString("VHOST_NAME");
    if (vhostName !== "") {
        cellery:WebIngress web = <cellery:WebIngress>portalComponent["ingresses"]["portal"];
        web["gatewayConfig"]["vhost"] = vhostName;
        web["gatewayConfig"]["oidc"]["redirectUrl"] = "http://" + vhostName + "/_auth/callback";
        web["gatewayConfig"]["oidc"]["baseUrl"] = "http://" + vhostName + "/";
    }

    cellery:WebIngress portalIngress = <cellery:WebIngress>portalComponent["ingresses"]["portal"];
    portalIngress["gatewayConfig"]["oidc"]["providerUrl"] = config:getAsString("providerUrl",
        "https://idp.cellery-system/oauth2/token");
    portalIngress["gatewayConfig"]["oidc"]["clientId"] = config:getAsString("clientId", "petstoreapplication");
    cellery:DCR dcrConfig = {
        dcrUser: config:getAsString("dcrUser", "admin"),
        dcrPassword: config:getAsString("dcrPassword", "admin")
    };
    portalIngress["gatewayConfig"]["oidc"]["clientSecret"] = dcrConfig;

    return <@untainted> cellery:createInstance(petStoreFrontendCell, iName, instances, startDependencies, shareDependencies);
}