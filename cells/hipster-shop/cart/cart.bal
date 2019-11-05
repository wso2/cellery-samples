import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    int cacheContainerPort = 6379;
    int cartContainerPort = 7070;

    // Cache component
    // Redis-based cache
    cellery:Component cacheServiceComponent = {
        name: "cache",
         src: {
            image: "redis:alpine"
        },
        ingresses: {
            tcpIngress: <cellery:TCPIngress> {
                backendPort: cacheContainerPort
            }
        }
    };

    // Cart service component
    // Stores the items in the user's shipping cart in Redis and retrieves it.
    cellery:Component cartServiceComponent = {
        name: "cart",
         src: {
            image: "gcr.io/google-samples/microservices-demo/cartservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress> {
                backendPort: cartContainerPort,
                gatewayPort: 31407
            }
        },
        envVars: {
            PORT: {
                value: cartContainerPort
            },
            REDIS_ADDR: {
                value: cellery:getHost(cacheServiceComponent) + ":" + cacheContainerPort.toString()
            },
            LISTEN_ADDR: {
                value: "0.0.0.0"
            },
            CART_SERVICE_ADDR: {
                value: ""
            }
        },
        dependencies: {
            components: [cacheServiceComponent]
        }
    };

    // Cell Initialization
    cellery:CellImage cartCell = {
        components: {
            cacheServiceComponent: cacheServiceComponent,
            cartServiceComponent: cartServiceComponent
        }
    };
    return <@untainted> cellery:createImage(cartCell,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage cartCell = check cellery:constructCellImage( iName);
    return <@untainted> cellery:createInstance(cartCell, iName, instances, startDependencies, shareDependencies);
}
