/*
 *  Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require("express");
const axios = require("axios");
const morgan = require("morgan");
const path = require("path");
const rotatingFileStream = require("rotating-file-stream");
const validate = require("express-validation");
const joi = require("joi");

const service = express();
const port = process.env.SERVICE_PORT || 3004;
const isGuestModeEnabled = Boolean(process.env.GUEST_MODE_ENABLED) || false;

const CATALOG_HOST = process.env.CATALOG_HOST;
const CATALOG_PORT = process.env.CATALOG_PORT;
const CUSTOMERS_HOST = process.env.CUSTOMER_HOST;
const CUSTOMERS_PORT = process.env.CUSTOMER_PORT;
const ORDERS_HOST = process.env.ORDER_HOST;
const ORDERS_PORT = process.env.ORDER_PORT;

const CATALOG_SERVICE_URL = "http://" + CATALOG_HOST + ":" + CATALOG_PORT;
const CUSTOMERS_SERVICE_URL = "http://" + CUSTOMERS_HOST + ":" + CUSTOMERS_PORT;
const ORDERS_SERVICE_URL = "http://" + ORDERS_HOST + ":" + ORDERS_PORT;

const CELLERY_USER_HEADER = "x-cellery-auth-subject";
const PET_STORE_GUEST_HEADER = "x-pet-store-guest";

const forwardedHeaders = [
    "Authorization",
    "x-request-id",
    "x-b3-traceid",
    "x-b3-spanid",
    "x-b3-parentspanid",
    "x-b3-sampled",
    "x-b3-flags",
    "x-ot-span-context",
    PET_STORE_GUEST_HEADER
];

const globalValidationOptions = {
    headers: {
        "content-type": joi.string().valid("application/json").insensitive().required(),
        "x-pet-store-guest": joi.string()
    }
};

service.use(express.json());

// Logger for access logs
const accessLogStream = rotatingFileStream("access.log", {
    interval: "1d",
    path: path.join(__dirname, "log")
});
service.use(morgan("combined", {
    stream: accessLogStream
}));

// Logger for 4xx and 5xx responses
morgan.token("log-level", (req, res) => {
    let logLevel = "INFO";
    if (res.statusCode >= 500) {
        logLevel = "ERROR";
    } else if (res.statusCode >= 400 && res.statusCode < 500) {
        logLevel = "WARN";
    }

    return logLevel;
});
service.use(morgan("[:log-level] access :method :url :status :response-time ms - :res[content-length]", {
    skip: (req, res) => res.statusCode < 400
}));

/**
 * Get the username of the user who invoked the API.
 *
 * @param req The express request object received
 * @return The username of the user who invoked the API
 */
const getUsername = (req) => {
    let username = null;
    if (req) {
        if (isGuestModeEnabled) {
            username = req.get(PET_STORE_GUEST_HEADER);
        } else {
            username = req.get(CELLERY_USER_HEADER);
        }
    }
    return username;
};

/**
 * Handle a success response from the API invocation.
 *
 * @param res The express response object
 * @param data The returned data from the API invocation
 */
const handleSuccess = (res, data) => {
    const response = {
        status: "SUCCESS"
    };
    if (data) {
        response.data = data;
    }
    res.send(response);
};

/**
 * Handle an error which occurred during the API invocation.
 *
 * @param res The express response object
 * @param message The error message
 */
const handleError = (res, message) => {
    console.error("[ERROR] " + message);
    res.status(500).send({
        status: "ERROR",
        message: message
    });
};

/**
 * Call an API.
 *
 * @param config Axios configuration to be used
 * @param req The received request object
 * @return {Promise<any>} The promise for the data fetch request
 */
const callAPI = (config, req) => new Promise((resolve, reject) => {
    if (!config.headers) {
        config.headers = {};
    }
    forwardedHeaders.forEach((header) => {
        const headerValue = req.get(header);
        if (headerValue) {
            config.headers[header] = headerValue;
        }
    });
    config.headers["Content-Type"] = "application/json";

    axios(config)
        .then((response) => {
            const responseBody = response.data;
            if (responseBody.status === "SUCCESS") {
                resolve(responseBody.data);
            } else {
                console.error("[ERROR] Failed to call API " + config.url + " using method " + config.method + " due to " +
                    responseBody.message);
                reject(new Error("Failed to fetch data"));
            }
        })
        .catch((error) => {
            console.error("[ERROR] Failed to call API " + config.url + " using method " + config.method + " due to " +
                error);
            reject(error);
        });
});

/**
 * Call an API in the Catalog Service.
 *
 * @param config The axios configuration with the endpoint as the URL
 * @param req The received request object
 * @return {Promise<any>} The promise for the data fetch request
 */
const callCatalogService = (config, req) => callAPI({
        ...config,
        url: CATALOG_SERVICE_URL + config.url
    }, req);

/**
 * Call an API in the Customers Service.
 *
 * @param config The axios configuration with the endpoint as the URL
 * @param req The received request object
 * @return {Promise<any>} The promise for the data fetch request
 */
const callCustomersService = (config, req) => callAPI({
        ...config,
        url: CUSTOMERS_SERVICE_URL + config.url
    }, req);

/**
 * Call an API in the Orders Service.
 *
 * @param config The axios configuration with the endpoint as the URL
 * @param req The received request object
 * @return {Promise<any>} The promise for the data fetch request
 */
const callOrdersService = (config, req) => callAPI({
        ...config,
        url: ORDERS_SERVICE_URL + config.url
    }, req);

/*
 * API endpoint for getting a list of accessories available in the catalog.
 */
service.get("/catalog", (req, res) => {
    const config = {
        url: "/accessories",
        method: "GET"
    };
    callCatalogService(config, req)
        .then((data) => {
            handleSuccess(res, {
                accessories: data
            });
        })
        .catch((error) => {
            handleError(res, "Failed to fetch catalog data due to " + error);
        });
});

/*
 * API endpoint for getting a list of accessories available in the catalog.
 */
service.get("/orders", (req, res) => {
    const ordersCallConfig = {
        url: "/orders",
        method: "GET"
    };
    const catalogCallConfig = {
        url: "/accessories",
        method: "GET"
    };
    Promise.all([
        callOrdersService(ordersCallConfig, req),
        callCatalogService(catalogCallConfig, req)
    ])
        .then((data) => {
            const orders = data[0];
            const accessories = data[1];
            orders.forEach((orderDatum) => {
                orderDatum.order = orderDatum.order.map((datum) => ({
                    item: accessories.find((accessory) => datum.id === accessory.id),
                    amount: datum.amount
                }));
            });
            handleSuccess(res, {
                orders: orders
            });
        })
        .catch((error) => {
            handleError(res, "Failed to fetch orders data due to " + error);
        });
});

const orderSchema = {
    order: joi.array().items(joi.object({
        id: joi.number().integer().greater(0).required(),
        amount: joi.number().integer().greater(0).required()
    })).required()
};

/*
 * API endpoint for getting a list of accessories available in the catalog.
 */
const postOrderValidationOptions = {
    body: orderSchema,
    ...globalValidationOptions
};
service.post("/orders", validate(postOrderValidationOptions), (req, res) => {
    const config = {
        url: "/orders",
        method: "POST",
        data: {
            order: req.body.order.map((orderItem) => ({
                id: orderItem.id,
                amount: orderItem.amount
            }))
        }
    };
    callOrdersService(config, req)
        .then((data) => {
            handleSuccess(res, data);
        })
        .catch((error) => {
            handleError(res, "Failed to place order due to " + error);
        });
});

/*
 * API endpoint for getting the user profile.
 */
service.get("/profile", (req, res) => {
    const username = getUsername(req);
    const config = {
        url: `/customers/${username}`,
        method: "GET"
    };
    callCustomersService(config, req)
        .then((data) => {
            handleSuccess(res, {
                profile: data
            });
        })
        .catch((error) => {
            handleError(res, "Failed to fetch profile due to " + error);
        });
});

const profileSchema = {
    firstName: joi.string().required(),
    lastName: joi.string().required(),
    address: joi.string().required(),
    pets: joi.array().items(joi.string().valid("Dog", "Cat", "Hamster")).min(1).required()
};

/*
 * API endpoint for creating the user profile.
 */
const postProfileValidationOptions = {
    body: profileSchema,
    ...globalValidationOptions
};
service.post("/profile", validate(postProfileValidationOptions), (req, res) => {
    const username = getUsername(req);
    const config = {
        url: "/customers",
        method: "POST",
        data: {
            username: username,
            firstName: req.body.firstName,
            lastName: req.body.lastName,
            address: req.body.address,
            pets: req.body.pets
        }
    };
    callCustomersService(config, req)
        .then(() => {
            handleSuccess(res);
        })
        .catch((error) => {
            handleError(res, "Failed to create profile due to " + error);
        });
});

// Error handler for validation errors
service.use(function (err, req, res, next) {
    if (err instanceof validate.ValidationError) {
        // At this point you can execute your error handling code
        console.error("[ERROR] Invalid incoming request " + req.method + " " + req.path, err);

        const errors = {};
        err.errors.forEach((validationErr) => {
            errors[validationErr.location] = {
                field: validationErr.field,
                messages: validationErr.messages,
                types: validationErr.types
            };
        });

        res.status(400).send({
            status: "BAD_REQUEST",
            message: "Invalid Request",
            errors: errors
        });
        next();
    } else {
        // Pass error on if not a validation error
        next(err);
    }
});

/*
 * Starting the server
 */
const server = service.listen(port, () => {
    const host = server.address().address;
    const port = server.address().port;

    console.log("[INFO] Pet Store Controller Service listening at http://%s:%s", host, port);
});

// Listening for os Signals to gracefully shutdown
const shutdownServer = () => {
    console.log("[INFO] Shutting down Pet Store Controller Service");
    server.close(() => {
        console.log("[INFO] Pet Store Controller Service shutdown complete");
        // eslint-disable-next-line no-process-exit
        process.exit(0);
    });
};
process.on("SIGTERM", shutdownServer);
process.on("SIGINT", shutdownServer);
