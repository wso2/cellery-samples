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


// Cell file for Hello world Sample
import celleryio/cellery;

// Hello Component
// This Components exposes the HTML hello world page
cellery:Component helloComponent = {
    name: "hello",
    source: {
        image: "wso2cellery/samples-hello-world-hello"
    },
    ingresses: {
        webUI: <cellery:WebIngress>{ // Web ingress will be always exposed globally.
            port: 8080,
            gatewayConfig: {
                vhost: "hello-world.com",
                context: "/"
            }
        }
    }
};

// Cell Initialization
cellery:CellImage helloCell = {
    components: {
        webComp: helloComponent
    }
};


# The Cellery Lifecycle Build method which is invoked for building the Cell Image.
#
# + iName - The Image name
# + return - The created Cell Image
public function build(cellery:ImageName iName) returns error? {
    return cellery:createImage(helloCell, iName);
}

# The Cellery Lifecycle Run method which is invoked for creating a Cell Instance.
#
# + iName - The Image name
# + instances - The map dependency instances of the Cell instance to be created
# + return - The Cell instance
public function run(cellery:ImageName iName, map<string> instances) returns error? {
    return cellery:createInstance(helloCell, iName);
}
