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

    // Orders Component
    // This component deals with all the orders related functionality.
    int ordersPort = 80;
    cellery:Component ordersComponent = {
        name: "orders",
        src: {
            image: "wso2cellery/samples-pet-store-orders:latest-dev"
        },
        ingresses: {
            orders:  <cellery:HttpPortIngress>{
                port: ordersPort
            }
        }
    };

    // Customers Component
    // This component deals with all the customers related functionality.
    int customerPort = 80;
    cellery:Component customersComponent = {
        name: "customers",
        src: {
            image: "wso2cellery/samples-pet-store-customers:latest-dev"
        },
        ingresses: {
            customers: <cellery:HttpPortIngress>{
                port: customerPort
            }
        }
    };

    // Catalog Component
    // This component deals with all the catalog related functionality.
    int catalogPort = 80;
    cellery:Component catalogComponent = {
        name: "catalog",
        src: {
            image: "wso2cellery/samples-pet-store-catalog:latest-dev"
        },
        ingresses: {
            catalog: <cellery:HttpPortIngress>{
                port: catalogPort
            }
        }
    };

    // Controller Component
    // This component deals depends on Orders, Customers and Catalog components.
    // This exposes useful functionality from the Cell by using the other three components.
    int controllerPort = 80;
    cellery:Component controllerComponent = {
        name: "controller",
        src: {
            image: "wso2cellery/samples-pet-store-controller:latest-dev"
        },
        ingresses: {
            ingress: <cellery:HttpPortIngress>{
                port: controllerPort
            }
        },
        envVars: {
            CATALOG_HOST: { value: cellery:getHost(catalogComponent) },
            CATALOG_PORT: { value: catalogPort },
            ORDER_HOST: { value: cellery:getHost(ordersComponent) },
            ORDER_PORT: { value: ordersPort },
            CUSTOMER_HOST: { value: cellery:getHost(customersComponent) },
            CUSTOMER_PORT: { value: customerPort }
        },
        dependencies: {
            components: [catalogComponent, ordersComponent, customersComponent]
        }
    };

    // Composite Initialization
    cellery:Composite petBE = {
        components: {
            catalog: catalogComponent,
            customer: customersComponent,
            orders: ordersComponent,
            controller: controllerComponent
        }
    };
    return <@untainted> cellery:createImage(petBE,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies)
       returns (cellery:InstanceState[]|error?) {
    cellery:Composite petBE = check cellery:constructImage( iName);
    return <@untainted> cellery:createInstance(petBE, iName, instances, startDependencies, shareDependencies);
}