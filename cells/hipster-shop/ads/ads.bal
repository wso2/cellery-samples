import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    int adsContainerPort = 9555;
    // Ad service component
    // This component provides text ads based on given context words.
    cellery:Component adsServiceComponent = {
        name: "ads",
         src: {
            image: "gcr.io/google-samples/microservices-demo/adservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
            backendPort: adsContainerPort,
            gatewayPort: 31406
        }
        },
        envVars: {
            PORT: {
                value: adsContainerPort
            }
        }
    };

    // Cell Initialization
    cellery:CellImage adsCell = {
        components: {
            adsServiceComponent: adsServiceComponent
        }
    };
    return <@untainted> cellery:createImage(adsCell,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage adsCell = check cellery:constructCellImage( iName);
    return <@untainted> cellery:createInstance(adsCell, iName, instances, startDependencies, shareDependencies);
}
