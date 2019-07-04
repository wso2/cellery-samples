# Cell-based Hipster Shop Application

All details of the original Hipster Shop: Cloud-Native Microservices Demo Application can be found [here](https://github.com/GoogleCloudPlatform/microservices-demo). 

The Hipster Shop project contains a 10-tier microservices application. The application is a
web-based e-commerce app called **“Hipster Shop”** where users can browse items,
add them to the cart, and purchase them.

## Screenshots

| Home Page                                                                                                         | Checkout Screen                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [![Screenshot of store homepage](./docs/img/hipster-shop-frontend-1.png)](./docs/img/hipster-shop-frontend-1.png) | [![Screenshot of checkout screen](./docs/img/hipster-shop-frontend-2.png)](./docs/img/hipster-shop-frontend-2.png) |


| Checkout Cell                                                                                                         | Frontend Cell                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [![Screenshot of checkout cell](./docs/img/hipster-shop-checkout.png)](./docs/img/hipster-shop-checkout.png) | [![Screenshot of front-end cell](./docs/img/hipstershop-front-end.png)](./docs/img/hipstershop-front-end.png) |


## Service Architecture

**Hipster Shop** is composed of many microservices written in different languages that talk to each other over gRPC.

[![Architecture of
microservices](./docs/img/architecture-diagram.png)](./docs/img/architecture-diagram.png)

| Service                                              | Language      | Description                                                                                                                       |
| ---------------------------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [frontend](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/frontend)                           | Go            | Exposes an HTTP server to serve the website. Does not require signup/login and generates session IDs for all users automatically. |
| [cartservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/cartservice)                     | C#            | Stores the items in the user's shipping cart in Redis and retrieves it.                                                           |
| [productcatalogservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/productcatalogservice) | Go            | Provides the list of products from a JSON file and ability to search products and get individual products.                        |
| [currencyservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/currencyservice)             | Node.js       | Converts one money amount to another currency. Uses real values fetched from European Central Bank. It's the highest QPS service. |
| [paymentservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/paymentservice)               | Node.js       | Charges the given credit card info (mock) with the given amount and returns a transaction ID.                                     |
| [shippingservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/shippingservice)             | Go            | Gives shipping cost estimates based on the shopping cart. Ships items to the given address (mock)                                 |
| [emailservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/emailservice)                   | Python        | Sends users an order confirmation email (mock).                                                                                   |
| [checkoutservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/checkoutservice)             | Go            | Retrieves user cart, prepares order and orchestrates the payment, shipping and the email notification.                            |
| [recommendationservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/recommendationservice) | Python        | Recommends other products based on what's given in the cart.                                                                      |
| [adservice](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/adservice)                         | Java          | Provides text ads based on given context words.                                                                                   |
| [loadgenerator](https://github.com/GoogleCloudPlatform/microservices-demo/tree/master/src/loadgenerator)                 | Python/Locust | Continuously sends requests imitating realistic user shopping flows to the frontend.                                              |

## Cell Architecture

**Hipster Shop** is composed of many microservices written in different
languages that talk to each other over gRPC. This sample is structured into 5 cells: 
- [ads-cell](ads)
- [products-cell](products)
- [cart-cell](cart)
- [checkout-cell](checkout)
- [front-end-cell](front-end)

[![Cell architecture of
Hipstershop services](./docs/img/hipstershop-cell-architecture.png)](./docs/img/hipstershop-cell-architecture.png)

## Build and Deploy the Hipstershop Cells
### Check Out Sample
Clone the hipstershop-cellery repository and 
navigate to the hipstershop-cellery sample. <br>
cd hipstershop-cellery/

Run the following command (required for cellery version 0.2.0 and if the setup is local)<br>
kubectl apply -f controller.yaml

### Build and Run <b>ads-cell</b>
cd hipstershop-cellery/ads-cell <br>
cellery build ads-cell.bal wso2/ads-cell:1.0.0 <br>

[![Cell architecture of Hipstershop services](./docs/img/ads-cell-build.png)](./docs/img/ads-cell-build.png)

cellery run wso2/ads-cell:1.0.0 -n ads-cell

[![Cell architecture of Hipstershop services](./docs/img/ads-cell-run.png)](./docs/img/ads-cell-run.png)


### Build and Run <b>products-cell</b>
cd hipstershop-cellery/products-cell<br>
cellery build products-cell.bal wso2/products-cell:1.0.0

[![Cell architecture of
Hipstershop services](./docs/img/products-cell-build.png)](./docs/img/products-cell-build.png)

cellery run wso2/products-cell:1.0.0 -n products-cell
[![Cell architecture of Hipstershop services](./docs/img/products-cell-run.png)](./docs/img/products-cell-run.png)

### Build and Run <b>cart-cell</b>
cd hipstershop-cellery/cart-cell<br>
cellery build cart-cell.bal wso2/cart-cell:1.0.0

[![Cell architecture of Hipstershop services](./docs/img/cart-cell-build.png)](./docs/img/cart-cell-build.png)

cellery run wso2/cart-cell:1.0.0 -n cart-cell
[![Cell architecture of Hipstershop services](./docs/img/cart-cell-run.png)](./docs/img/cart-cell-run.png)

### Build and Run <b>checkout-cell</b>
cd hipstershop-cellery/checkout-cell<br>
cellery build checkout-cell.bal wso2/checkout-cell:1.0.0
[![Cell architecture of Hipstershop services](./docs/img/checkout-cell-build.png)](./docs/img/checkout-cell-build.png)

cellery run wso2/checkout-cell:1.0.0 -n checkout-cell -l cartCellDep:cart-cell -l productsCellDep:products-cell -d
[![Cell architecture of Hipstershop services](./docs/img/checkout-cell-run.png)](./docs/img/checkout-cell-run.png)

### Build and Run <b>frontend-cell</b>
cd hipstershop-cellery/front-end-cell<br>
cellery build front-end-cell.bal wso2/front-end-cell:1.0.0
[![Cell architecture of Hipstershop services](./docs/img/front-end-cell-build.png)](./docs/img/front-end-cell-build.png)

cellery run wso2/front-end-cell:1.0.0 -n front-end-cell -l cartCellDep:cart-cell -l productsCellDep:products-cell -l adsCellDep:ads-cell -l checkoutCellDep:checkout-cell -d

[![Cell architecture of Hipstershop services](./docs/img/front-end-cell-run.png)](./docs/img/front-end-cell-run.png)

### Viewing the Cells

Now all the application cells are deployed. Run the following command to see the status of the deployed cells.

cellery list instances

[![Cell architecture of Hipstershop services](./docs/img/list-instances.png)](./docs/img/list-instances.png)


Run cellery view command to see the components of your cell. This will open a HTML page in a browser and you can visualize the components and dependent cells of the cell image.

cellery view wso2/ads-cell:1.0.0

[![Cell architecture of Hipstershop services](./docs/img/ads-cell-view.png)](./docs/img/ads-cell-view.png)

cellery view wso2/products-cell:1.0.0

[![Cell architecture of Hipstershop services](./docs/img/products-cell-view.png)](./docs/img/products-cell-view.png)

cellery view wso2/cart-cell:1.0.0

[![Cell architecture of Hipstershop services](./docs/img/cart-cell-view.png)](./docs/img/cart-cell-view.png)

cellery view wso2/checkout-cell:1.0.0

[![Cell architecture of Hipstershop services](./docs/img/checkout-cell-view.png)](./docs/img/checkout-cell-view.png)

cellery view wso2/front-end-cell:1.0.0

[![Cell architecture of Hipstershop services](./docs/img/front-end-cell-view.png)](./docs/img/front-end-cell-view.png)


### Viewing the Application
Add the following line to /etc/hosts file: 
127.0.0.1	my-hipstershop.com

Access url http://my-hipstershop.com/ from a browser.

[![Cell architecture of Hipstershop services](./docs/img/hipstershop-application.png)](./docs/img/hipstershop-application.png)

[![Cell architecture of Hipstershop services](./docs/img/hipstershop-application-cart.png)](./docs/img/hipstershop-application-cart.png)
