import celleryio/cellery;

public function build(cellery:ImageName iName) returns error? {
    int emailContainerPort = 8080;
    int paymentContainerPort = 50051;
    int shippingContainerPort = 50051;
    int currencyContainerPort = 7000;
    int checkoutContainerPort = 5050;
    
    // Email service component
    // Sends users an order confirmation email (mock).
    cellery:Component emailServiceComponent = {
        name: "email",
         src: {
            image: "gcr.io/google-samples/microservices-demo/emailservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
                backendPort: emailContainerPort
            }
        },
        envVars: {
            PORT: {
                value: emailContainerPort
            },
            ENABLE_PROFILER: {
                value: 0
            }
        }
    };

    // Payment service component
    // Charges the given credit card info (mock) with the given amount and returns a transaction ID.
    cellery:Component paymentServiceComponent = {
        name: "payment",
         src: {
            image: "gcr.io/google-samples/microservices-demo/paymentservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
                backendPort: paymentContainerPort
            }
        },
        envVars: {
            PORT: {
                value: paymentContainerPort
            }
        }
    };

    // Shipping service component
    // Gives shipping cost estimates based on the shopping cart. Ships items to the given address (mock)
    cellery:Component shippingServiceComponent = {
        name: "shipping",
         src: {
            image: "gcr.io/google-samples/microservices-demo/shippingservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
                backendPort: shippingContainerPort,
                gatewayPort: 31407
            }
        },
        envVars: {
            PORT: {
                value: shippingContainerPort
            }
        }
    };

    // Currency service component
    // Converts one money amount to another currency.
    // Uses real values fetched from European Central Bank. It's the highest QPS service.
    cellery:Component currencyServiceComponent = {
        name: "currency",
         src: {
            image: "gcr.io/google-samples/microservices-demo/currencyservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
                backendPort: currencyContainerPort,
                gatewayPort: 31408
        }
        },
        envVars: {
            PORT: {
                value: currencyContainerPort
            }
        }
    };

    // Checkout service component
    // Retrieves user cart, prepares order and orchestrates the payment,
    // shipping and the email notification.

    cellery:Component checkoutServiceComponent = {
        name: "checkout",
         src: {
            image: "gcr.io/google-samples/microservices-demo/checkoutservice:v0.1.1"
        },
        ingresses: {
            grpcIngress: <cellery:GRPCIngress>{
                backendPort: checkoutContainerPort,
                gatewayPort: 31409
        }
        },
        envVars: {
            PORT: {
                value: checkoutContainerPort
            },
            //same-cell components
            EMAIL_SERVICE_ADDR: {
                value: cellery:getHost(emailServiceComponent) + ":" + emailContainerPort.toString()
            },
            PAYMENT_SERVICE_ADDR: {
                value: cellery:getHost(paymentServiceComponent) + ":" + paymentContainerPort.toString()
            },
            SHIPPING_SERVICE_ADDR: {
                value: cellery:getHost(shippingServiceComponent) + ":" + shippingContainerPort.toString()
            },
            CURRENCY_SERVICE_ADDR: {
                value: cellery:getHost(currencyServiceComponent) + ":" + currencyContainerPort.toString()
            },
            //components of external cells
            PRODUCT_CATALOG_SERVICE_ADDR: {
                value: ""
            },
            CART_SERVICE_ADDR: {
                value: ""
            }
        },
        dependencies: {
            components: [emailServiceComponent, paymentServiceComponent, shippingServiceComponent, currencyServiceComponent],
            cells: {
                productsCellDep: <cellery:ImageName>{ org: "wso2cellery", name: "products-cell", ver: "latest-dev"},
                cartCellDep: <cellery:ImageName> { org: "wso2cellery", name: "cart-cell", ver: "latest-dev" }
            }
        }
    };

    cellery:Reference productReference = cellery:getReference(checkoutServiceComponent, "productsCellDep");
    checkoutServiceComponent["envVars"]["PRODUCT_CATALOG_SERVICE_ADDR"].value = <string>productReference["gateway_host"] + ":" +<string>productReference["products_grpc_port"];

    cellery:Reference cartReference = cellery:getReference(checkoutServiceComponent, "cartCellDep");
    checkoutServiceComponent["envVars"]["CART_SERVICE_ADDR"].value = <string>cartReference["gateway_host"] + ":" +<string>cartReference["cart_grpc_port"];

    // Cell Initialization
    cellery:CellImage checkoutCell = {
        components: {
            emailServiceComponent: emailServiceComponent,
            paymentServiceComponent: paymentServiceComponent,
            shippingServiceComponent: shippingServiceComponent,
            currencyServiceComponent: currencyServiceComponent,
            checkoutServiceComponent: checkoutServiceComponent
        }
    };
    return <@untainted> cellery:createImage(checkoutCell,  iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances, boolean startDependencies, boolean shareDependencies) returns (cellery:InstanceState[]|error?) {
    cellery:CellImage checkoutCell = check cellery:constructCellImage( iName);
    return <@untainted> cellery:createInstance(checkoutCell, iName, instances, startDependencies, shareDependencies);
}

