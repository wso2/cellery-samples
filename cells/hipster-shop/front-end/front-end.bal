import ballerina/config;
import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    int frontEndPort = 80;

    // Front-end service component
    // Exposes an HTTP server to serve the website.
    // Does not require signup/login and generates session IDs for all users automatically.

    cellery:Component frontEndComponent = {
        name: "front-end",
        source: {
            image: "gcr.io/google-samples/microservices-demo/frontend:v0.1.1"
        },
        ingresses: {
            portal: <cellery:WebIngress> { // Web ingress will be always exposed globally.
            port: frontEndPort,
            gatewayConfig: {
                vhost: "my-hipstershop.com",
                context: "/"
                }
            }
        },
        envVars: {
            PORT: {
                value: frontEndPort
            },
            PRODUCT_CATALOG_SERVICE_ADDR: {
                value: ""
            },
            CURRENCY_SERVICE_ADDR: {
                value: ""
            },
            CART_SERVICE_ADDR: {
                value: ""
            },
            RECOMMENDATION_SERVICE_ADDR: {
                value: ""
            },
            SHIPPING_SERVICE_ADDR: {
                value: ""
            },
            CHECKOUT_SERVICE_ADDR: {
                value: ""
            },
            AD_SERVICE_ADDR: {
                value: ""
            }
        },
        dependencies: {
            cells: {
                productsCellDep: <cellery:ImageName>{ org: "wso2cellery", name: "products-cell", ver: "0.3.0"},
                adsCellDep: <cellery:ImageName>{ org: "wso2cellery", name: "ads-cell", ver: "0.3.0"},
                cartCellDep: <cellery:ImageName>{ org: "wso2cellery", name: "cart-cell", ver: "0.3.0"},
                checkoutCellDep: <cellery:ImageName>{ org: "wso2cellery", name: "checkout-cell", ver: "0.3.0"}
            }
        }
    };

    cellery:Reference productReference = cellery:getReference(frontEndComponent, "productsCellDep");
    frontEndComponent.envVars.PRODUCT_CATALOG_SERVICE_ADDR.value = <string>productReference.gateway_host + ":" +<string>productReference.products_grpc_port;
    frontEndComponent.envVars.RECOMMENDATION_SERVICE_ADDR.value = <string>productReference.gateway_host + ":" +<string>productReference.recommendations_grpc_port;

    cellery:Reference checkoutReference = cellery:getReference(frontEndComponent, "checkoutCellDep");
    frontEndComponent.envVars.CURRENCY_SERVICE_ADDR.value = <string>checkoutReference.gateway_host + ":" +<string>checkoutReference.currency_grpc_port;
    frontEndComponent.envVars.SHIPPING_SERVICE_ADDR.value = <string>checkoutReference.gateway_host + ":" +<string>checkoutReference.shipping_grpc_port;
    frontEndComponent.envVars.CHECKOUT_SERVICE_ADDR.value = <string>checkoutReference.gateway_host + ":" +<string>checkoutReference.checkout_grpc_port;

    cellery:Reference cartReference = cellery:getReference(frontEndComponent, "cartCellDep");
    frontEndComponent.envVars.CART_SERVICE_ADDR.value = <string>cartReference.gateway_host + ":" +<string>cartReference.cart_grpc_port;

    cellery:Reference adsReference = cellery:getReference(frontEndComponent, "adsCellDep");
    frontEndComponent.envVars.AD_SERVICE_ADDR.value = <string>adsReference.gateway_host + ":" +<string>adsReference.ads_grpc_port;

    // Cell Initialization
    cellery:CellImage frontEndCell = {
        components: {
            frontEndComponent: frontEndComponent
        }
    };
    return cellery:createImage(frontEndCell, untaint iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    cellery:CellImage frontEndCell = check cellery:constructCellImage(untaint iName);
    return cellery:createInstance(frontEndCell, iName, instances);
}