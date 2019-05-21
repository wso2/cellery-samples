## Pet store pet-be cell

This pet store backend cell consists of 4 microservices.

* Catalog (Catalog of the accessories available in the pet store)
* Customers (Existing customers of the Pet Store)
* Orders (Orders placed at the Pet Store by Customers)
* Controller (Controller service which fetches data from the above 3 microservices and processes them to provide useful functionality)

All 4 micro services are implemented in [node.js](https://nodejs.org/en/). 


### Pet-be cell
The below shown is the cell file for the pet-be cell which is in [pet-be.bal](pet-be/pet-be.bal).

```
import celleryio/cellery;

// Orders Component
// This component deals with all the orders related functionality.
cellery:Component ordersComponent = {
    name: "orders",
    source: {
        image: "wso2cellery/samples-pet-store-orders:0.2.1"
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
    source: {
        image: "wso2cellery/samples-pet-store-customers:0.2.1"
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
    source: {
        image: "wso2cellery/samples-pet-store-catalog:0.2.1"
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
    source: {
        image: "wso2cellery/samples-pet-store-controller"
    },
    ingresses: {
        controller: <cellery:HttpApiIngress>{
            port: 80,
            context: "controller",
            expose: "local"
        }
    },
    envVars: {
        CATALOG_HOST: {value: ""},
        CATALOG_PORT: {value: 80},
        ORDER_HOST: {value: ""},
        ORDER_PORT: {value: 80},
        CUSTOMER_HOST: {value: ""},
        CUSTOMER_PORT: {value: 80}

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

# The Cellery Lifecycle Build method which is invoked for building the Cell Image.
#
# + iName - The Image name
# + return - The created Cell Image
public function build(cellery:ImageName iName) returns error? {
    cellery:ApiDefinition controllerApiDef = (<cellery:ApiDefinition>cellery:readSwaggerFile(
        "./components/controller/resources/pet-store.swagger.json"));
    cellery:HttpApiIngress controllerApi = <cellery:HttpApiIngress>(controllerComponent.ingresses.controller);
    controllerApi.definition = controllerApiDef;

    return cellery:createImage(petStoreBackendCell, iName);
}

# The Cellery Lifecycle Run method which is invoked for creating a Cell Instance.
#
# + iName - The Image name
# + instances - The map dependency instances of the Cell instance to be created
# + return - The Cell instance
public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    petStoreBackendCell.components.controller.envVars.CATALOG_HOST.value = cellery:getHost(untaint iName.instanceName, catalogComponent);
    petStoreBackendCell.components.controller.envVars.ORDER_HOST.value = cellery:getHost(untaint iName.instanceName, ordersComponent);
    petStoreBackendCell.components.controller.envVars.CUSTOMER_HOST.value = cellery:getHost(untaint iName.instanceName, customersComponent);

    return cellery:createInstance(petStoreBackendCell, iName);
}
```

- There are four components defined to deploy four micro-services (catalog, orders, customers, and controller), and all four components have HTTP ingress to receive the external requests. 
- Only `controller` component has defined `expose` parameter to `local` in the [HttpAPIIngress](https://github.com/wso2-cellery/spec#1-http-ingresses), 
and therefore only `controller` component is exposed as cell API, and all other three components are only accessible within the cell and not from other cells. 
- The `controller` component cell has defined `envVars` to get the runtime value of host and ports for other components catalog, customer, and orders. 
- All four components are defined included in the cell during `petStoreBackendCell` initialization.

### Build method 
- The `build` method will be executed when `cellery build` is performed, and user can pass the `cellery:ImageName iName` as a parameter during cellery build.
- The API definition of the controller micro service is defined in the swagger file [pet-store.swagger.json](pet-be/components/controller/resources/pet-store.swagger.json). 
And therefore the controller component's HttpAPIIngress's API definition is updated by reading the swagger file in the `build` method.
- Finally, the method `cellery:createImage` within the `build` method will create the cell image.

### Run method
- The `run` method will be executed when `cellery run` is performed.
- `cellery:ImageName iName` will be passed into the run method which will have both cell image and the corresponding instance name that the cellery runtime should spawn.
- As the cell image is already built during `build` method, users can only change the `envVars` in the component and pass those as runtime values.
- `cellery:getHost` method will return the actual host value of other micro-services components so that respective `envVars` will be properly set at the `controller` component.
- Finally, the method `cellery:createInstance` will spawn an instance of the `cellery:ImageName iName`
