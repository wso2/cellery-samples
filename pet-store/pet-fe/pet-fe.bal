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

// Portal Component
// This is the Component which exposes the Pet Store portal
cellery:Component portalComponent = {
    name: "portal",
    source: {
        image: "wso2cellery/samples-pet-store-portal"
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
        petStoreBackend: <cellery:ImageName>{ org: "wso2cellery", name: "pet-be-cell", ver: "latest" }
    }
};

// Cell Initialization
cellery:CellImage petStoreFrontendCell = {
    components: {
        portal: portalComponent
    }
};

# The Cellery Lifecycle Build method which is invoked for building the Cell Image.
#
# + iName - The Image name
# + return - The created Cell Image
public function build(cellery:ImageName iName) returns error? {
    return cellery:createImage(petStoreFrontendCell, iName);
}

# The Cellery Lifecycle Run method which is invoked for creating a Cell Instance.
#
# + iName - The Image name
# + instances - The map dependency instances of the Cell instance to be created
# + return - The Cell instance
public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    string vhostName = config:getAsString("VHOST_NAME");
    if (vhostName !== "") {
        cellery:WebIngress web = <cellery:WebIngress>portalComponent.ingresses.portal;
        web.gatewayConfig.vhost = vhostName;
        web.gatewayConfig.oidc.redirectUrl = "http://" + vhostName + "/_auth/callback";
        web.gatewayConfig.oidc.baseUrl = "http://" + vhostName + "/";
    }

    cellery:Reference petStoreBackendRef = check cellery:getReference(instances.petStoreBackend);
    portalComponent.envVars.PET_STORE_CELL_URL.value = <string>petStoreBackendRef.controller_api_url;

    cellery:WebIngress portalIngress = <cellery:WebIngress>portalComponent.ingresses.portal;
    portalIngress.gatewayConfig.oidc.providerUrl = config:getAsString("providerUrl", default =
        "https://idp.cellery-system/oauth2/token");
    portalIngress.gatewayConfig.oidc.clientId = config:getAsString("clientId", default = "petstoreapplication");
    cellery:DCR dcrConfig = {
        dcrUser: config:getAsString("dcrUser", default = "admin"),
        dcrPassword: config:getAsString("dcrPassword", default = "admin")
    };
    portalIngress.gatewayConfig.oidc.clientSecret = dcrConfig;

    return cellery:createInstance(petStoreFrontendCell, iName);
}
