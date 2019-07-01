## Pet store pet-fe cell
The portal web application is a [React](https://reactjs.org/) application, and it invokes the pet-be cell to get the 
data based on the business logic and logged in user. 

### Development of portal app
- The front end logic is written in [React](https://reactjs.org/), and it make calls to pet-be.
- The swagger file of the pet-fe can be fetched by executing command [`cellery extract-resources`](https://github.com/wso2-cellery/sdk/blob/master/docs/cli-reference.md#extract-resources) 
which will extract the swagger file in the same location where you run the command.
  ```
  cellery extract-resources wso2cellery/cells-pet-fe:latest
  ```
- Then based on the swagger file, the [client source](../../../src/pet-store/pet-fe/portal/src/gen/petStoreApi.js) is generated which can be used to invoke the pet-fe cell.

### Pet-fe cell
The below shown is the cell file for the pet-fe cell which is in [pet-fe.bal](pet-fe.bal).
```ballerina
import celleryio/cellery;
import ballerina/config;

# The Cellery Lifecycle Build method which is invoked for building the Cell Image.
#
# + iName - The Image name
# + return - The created Cell Image
public function build(cellery:ImageName iName) returns error? {
    // Portal Component
    // This is the Component which exposes the Pet Store portal
    cellery:Component portalComponent = {
        name: "portal",
        source: {
            image: "wso2cellery/samples-pet-store-portal:latest"
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
            cells: {
                petStoreBackend: <cellery:ImageName>{ org: "wso2cellery", name: "pet-be-cell", ver: "latest" }
            }
        }
    };

    // Assign the URL of the backend cell
    portalComponent.envVars.PET_STORE_CELL_URL.value = <string>cellery:getReference(portalComponent, "petStoreBackend").
    controller_api_url;

    // Cell Initialization
    cellery:CellImage petStoreFrontendCell = {
        components: {
            portal: portalComponent
        }
    };
    return cellery:createImage(petStoreFrontendCell, untaint iName);
}

# The Cellery Lifecycle Run method which is invoked for creating a Cell Instance.
#
# + iName - The Image name
# + instances - The map dependency instances of the Cell instance to be created
# + return - The Cell instance
public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    cellery:CellImage petStoreFrontendCell = check cellery:constructCellImage(untaint iName);
    cellery:Component portalComponent = petStoreFrontendCell.components.portal;
    string vhostName = config:getAsString("VHOST_NAME");
    if (vhostName !== "") {
        cellery:WebIngress web = <cellery:WebIngress>portalComponent.ingresses.portal;
        web.gatewayConfig.vhost = vhostName;
        web.gatewayConfig.oidc.redirectUrl = "http://" + vhostName + "/_auth/callback";
        web.gatewayConfig.oidc.baseUrl = "http://" + vhostName + "/";
    }

    cellery:WebIngress portalIngress = <cellery:WebIngress>portalComponent.ingresses.portal;
    portalIngress.gatewayConfig.oidc.providerUrl = config:getAsString("providerUrl", default =
        "https://idp.cellery-system/oauth2/token");
    portalIngress.gatewayConfig.oidc.clientId = config:getAsString("clientId", default = "petstoreapplication");
    cellery:DCR dcrConfig = {
        dcrUser: config:getAsString("dcrUser", default = "admin"),
        dcrPassword: config:getAsString("dcrPassword", default = "admin")
    };
    portalIngress.gatewayConfig.oidc.clientSecret = dcrConfig;

    return cellery:createInstance(petStoreFrontendCell, iName, instances);
}
```

#### Build method
- The pet-fe cell consists of one component `portalComponent` which has a web ingress that is exposed globally by default.
- The `gatewayConfig` in the `portalComponent` defines the configurations such as [OIDC](https://openid.net/connect/) configurations, 
vhost and context properties. By default all context of the `portalComponent` is secured and hence when the user tries to access the any page in the `portalComponent`, 
the user will be redirected to login page. 
- As `portalComponent` has a landing page which is not secured, `nonSecurePaths` is defined with contexts `["/", "/app/*"]`.
- The secured configurations of the `oidc` elements are left blank, and it'll be populated during the runtime by extracting the runtime configurations provided by user.
- The pet-fe cell depends on pet-be cell, and it's defined in the `dependencies` section in the `portalComponent`.
- As the pet-fe cell depends on pet-be cell, method `cellery:getReference(portalComponent, "petStoreBackend").controller_api_url` will help to resolve the actual controller API url in `portalComponent`.
- The build method is executed when `cellery build` is performed, and it creates the cell image with the method `cellery:createImage`.

#### Run method
- The `run` method will be executed when `cellery run` is performed.
- `cellery:ImageName iName` will be passed into the run method which will have both cell image and the corresponding instance name that the cellery runtime should spawn.
- The `oidc` configurations such as `providerUrl`, `clientId`, `dcrUser`, and `dcrPassword` are loaded from the runtime parameters, and will use the default values if there is no runtime parameters provided.
- Finally, the method `cellery:createInstance` will spawn an instance of the `cellery:ImageName iName`
