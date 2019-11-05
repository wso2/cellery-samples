## Pet store pet-be cell

This pet store backend cell consists of 4 microservices.

* Catalog (Catalog of the accessories available in the pet store)
* Customers (Existing customers of the Pet Store)
* Orders (Orders placed at the Pet Store by Customers)
* Controller (Controller service which fetches data from the above 3 microservices and processes them to provide useful functionality)

All 4 micro services are implemented in [node.js](https://nodejs.org/en/). 


### Pet-be cell
The below shown is the cell file for the pet-be cell which is in [pet-be.bal](pet-be.bal).

```bash
import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {

    // Orders Component
    // This component deals with all the orders related functionality.
    cellery:Component ordersComponent = {
        name: "orders",
        src: {
            image: "wso2cellery/samples-pet-store-orders:latest-dev"
        },
        ingresses: {
            orders: <cellery:HttpApiIngress>{
                port: 80
            }
        }
    };

    // Customers Component
    // This component deals with all the customers related functionality.
    cellery:Component customersComponent = {
        name: "customers",
        src: {
            image: "wso2cellery/samples-pet-store-customers:latest-dev"
        },
        ingresses: {
            customers: <cellery:HttpApiIngress>{
                port: 80
            }
        }
    };

    // Catalog Component
    // This component deals with all the catalog related functionality.
    cellery:Component catalogComponent = {
        name: "catalog",
        src: {
            image: "wso2cellery/samples-pet-store-catalog:latest-dev"
        },
        ingresses: {
            catalog: <cellery:HttpApiIngress>{
                port: 80
            }
        }
    };

    // Controller Component
    // This component deals depends on Orders, Customers and Catalog components.
    // This exposes useful functionality from the Cell by using the other three components.
    cellery:Component controllerComponent = {
        name: "controller",
        src: {
            image: "wso2cellery/samples-pet-store-controller:latest-dev"
        },
        ingresses: {
            ingress: <cellery:HttpApiIngress>{
                port: 80,
                context: "/controller",
                expose: "local",
                definition: <cellery:ApiDefinition>cellery:readSwaggerFile(
                                                       "./resources/pet-store.swagger.json")
            }
        },
        envVars: {
            CATALOG_HOST: { value: cellery:getHost(catalogComponent) },
            CATALOG_PORT: { value: 80 },
            ORDER_HOST: { value: cellery:getHost(ordersComponent) },
            ORDER_PORT: { value: 80 },
            CUSTOMER_HOST: { value: cellery:getHost(customersComponent) },
            CUSTOMER_PORT: { value: 80 }
        },
        dependencies: {
            components: [catalogComponent, ordersComponent, customersComponent]
        }
    };

    // Cell Initialization
    cellery:CellImage petStoreBackendCell = {
        components: {
            catalog: catalogComponent,
            customer: customersComponent,
            orders: ordersComponent,
            controller: controllerComponent
        }
    };
    return <@untainted> cellery:createImage(petStoreBackendCell,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage petStoreBackendCell = check cellery:constructCellImage( iName);
    return <@untainted> cellery:createInstance(petStoreBackendCell, iName, instances, startDependencies, shareDependencies);
}

public function test(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns error? {
    cellery:InstanceState[]|error? result = run(iName, instances, startDependencies, shareDependencies);
    cellery:InstanceState[] instanceList = [];
    if (result is error) {
        cellery:InstanceState iNameState = {
            iName : iName,
            isRunning: true
        };
        instanceList = [iNameState];
    } else {
        instanceList = <cellery:InstanceState[]>result;
    }

    cellery:ImageName img = <cellery:ImageName>cellery:getCellImage();
    cellery:Test petBeDockerTests = {
        name: "pet-be-test",
        src: {
            image: "docker.io/wso2cellery/pet-be-tests"
        },
        envVars: {
            PET_BE_CELL_URL: { value: <string>cellery:resolveReference(img)["controller_ingress_api_url"] }
        }
    };
    cellery:Test petBeInlineTests = {
        name: "pet-be-test",
        src : <cellery:FileSource> {
            filepath: "tests/"
        }
    };
    cellery:TestSuite petBeTestSuite = {
        tests: [petBeDockerTests, petBeInlineTests]
    };

    error? a = cellery:runTestSuite(instanceList, petBeTestSuite);
    return cellery:stopInstances(instanceList);
}
```
### Build method 
- The `build` method will be executed when `cellery build` is performed, and user can pass the `cellery:ImageName iName` as a parameter during cellery build. 
And therefore the controller component's HttpAPIIngress's API definition is updated by reading the swagger file in the `build` method.
- There are four components defined to deploy four micro-services (catalog, orders, customers, and controller), and all four components have HTTP ingress to receive the external requests. 
- Only `controller` component has defined `expose` parameter to `local` in the [HttpAPIIngress](https://github.com/wso2-cellery/spec#1-http-ingresses), 
and therefore only `controller` component is exposed as cell API, and all other three components are only accessible within the cell and not from other cells.
- The API definition of the controller micro service is defined in the swagger file [pet-store.swagger.json](../../../src/pet-store/pet-be/controller/resources/pet-store.swagger.json). 
- The `controller` component cell has defined `envVars` to get the runtime value of host and ports for other components catalog, customer, and orders. 
- All four components are defined included in the cell during `petStoreBackendCell` initialization.
- `cellery:getHost` method will return the actual host value of other micro-services components so that respective `envVars` will be properly set at the `controller` component.
- Finally, the method `cellery:createImage` within the `build` method will create the cell image.

### Run method
- The `run` method will be executed when `cellery run` is performed.
- `cellery:ImageName iName` will be passed into the run method which will have both cell image and the corresponding instance name that the cellery runtime should spawn.
- As the cell image is already built during `build` method, users can only change the `envVars` in the component and pass those as runtime values.
- Finally, the method `cellery:createInstance` will spawn an instance of the `cellery:ImageName iName`
