Pet Store
=========

Pet Store is a web portal which can be used by the customers for ordering accessories for their Pets.

This sample is a simple webapp which consists of 5 Docker images (4 microservices and a container to serve the web portal). 

* Catalog (Catalog of the accessories available in the pet store)
* Customers (Existing customers of the Pet Store)
* Orders (Orders placed at the Pet Store by Customers)
* Controller (Controller service which fetches data from the above 3 microservices and processes them to provide useful functionality)
* Portal (A simple Node JS container serving a React App with Server Side Rendering)

All 4 micro services are implemented in [node.js](https://nodejs.org/en/) and portal web application is a [React](https://reactjs.org/) application. 

This scenario has also been implemented by using cells, and you can find more information about that in the [Pet-store cells sample](../../cells/pet-store). 

Here, we wanted to demonstrate the same scenario by using the composites. Composites are simply a group of components, 
and it do not have control over inter-communication between components. Further, unlike cells, composites do not have network boundary or 
cell gateway to control the incoming and traffic cells. Therefore, composites will not have default ingress rules or OIDC flow created as we have 
demonstrated in the [pet-store cells](../../cells/pet-store/pet-fe#build-method), and the users will have to perform operations 
such as creating ingress manually to allow the traffic into the composites. 

In this sample, we demonstrate the use of composites with pet-store application, and this can be packaged 
and deployed in three different combinations as mentioned below. 

### 1. [All-in-one Composite](all-in-one-composite)
In this approach, all 5 components involved in the pet-store application is grouped together as a single composite. As this is a single composite in this,
users will have to create the ingress rules to allow the external traffic into the pet-store application. You can find more information about the detailed steps [here](all-in-one-composite). 

### 2. [Composite to Composite](composite-to-composite)
In this approach, both frontend and backend components have been separated into two composites and deployed. We will have to create the 
ingress manually to allow the external traffic into the portal application as we have performed in [All-in-one Compsite](#1-all-in-one-compositeall-in-one-composite). 
You can find more information about the detailed steps [here](composite-to-composite). 

### 3. [Cell to Composite](cell-to-composite)
In this approach, the frontend(portal) application of the pet-store is deployed as a Cell and the backend components are grouped as Composite. Since the front end
application is deployed as a Cell, the ingress rules are created by default by Cellery similar to the [Pet-store cells sample](../../cells/pet-store). 
You can find more information about the detailed steps [here](cell-to-composite).

# Did you try? 
1. [Hello world composite](../hello-world)
2. [Todo composite](../todo-service)
3. [Hello world cell](../../cells/hello-world)

