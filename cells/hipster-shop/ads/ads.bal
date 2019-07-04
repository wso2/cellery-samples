import ballerina/config;
import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    int adsContainerPort = 9555;
    // Ad service component
    // This component provides text ads based on given context words.
    cellery:Component adsServiceComponent = {
        name: "ads",
        source: {
            image: "gcr.io/google-samples/microservices-demo/adservice:v0.1.1"
        },
        ingresses: {
            tcpIngress: <cellery:TCPIngress>{
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
    return cellery:createImage(adsCell, untaint iName);
}
public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    cellery:CellImage adsCell = check cellery:constructCellImage(untaint iName);
    return cellery:createInstance(adsCell, iName, instances);
}
