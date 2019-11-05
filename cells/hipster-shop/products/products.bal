import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    int productCatalogContainerPort = 3550;
    int recommendationsContainerPort = 8080;

    // Product catalog service component
    // This component provides the list of products
    // from a JSON file and ability to search products and get individual products.
    cellery:Component productCatalogServiceComponent = {
        name: "products",
         src: {
            image: "gcr.io/google-samples/microservices-demo/productcatalogservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
            backendPort: productCatalogContainerPort,
            gatewayPort: 31406
        }
        },
        envVars: {
            PORT: {
                value: productCatalogContainerPort
            }
        }
    };

    // Recommendation service component
    // Recommends other products based on what's given in the cart.
    cellery:Component recommendationServiceComponent = {
        name: "recommendations",
         src: {
            image: "gcr.io/google-samples/microservices-demo/recommendationservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
            backendPort: recommendationsContainerPort,
            gatewayPort: 31407
        }
        },
        envVars: {
            PORT: {
                value: recommendationsContainerPort
            },
            // PRODUCT_CATALOG_SERVICE_ADDR: {value: "hipstershop_productcatalogservice:3550"},
            PRODUCT_CATALOG_SERVICE_ADDR: {
                value: cellery:getHost(productCatalogServiceComponent) + ":" + productCatalogContainerPort.toString()
            },
            ENABLE_PROFILER: {
                value: 0
            }
        },
        dependencies: {
            components: [productCatalogServiceComponent]
        }
    };

    // Cell Initialization
    cellery:CellImage productsCell = {
        components: {
            productCatalogServiceComponent: productCatalogServiceComponent,
            recommendationServiceComponent: recommendationServiceComponent
        }
    };
    return <@untainted> cellery:createImage(productsCell,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage productCell = check cellery:constructCellImage( iName);
    return <@untainted> cellery:createInstance(productCell, iName, instances, startDependencies, shareDependencies);
}
