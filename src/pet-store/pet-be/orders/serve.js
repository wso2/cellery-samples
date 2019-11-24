/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const express = require("express");
const fs = require("fs");
const moment = require("moment");
const morgan = require("morgan");
const path = require("path");
const rotatingFileStream = require("rotating-file-stream");
const validate = require("express-validation");
const joi = require("joi");

const service = express();
const port = process.env.SERVICE_PORT || 3003;
const isGuestModeEnabled = Boolean(process.env.GUEST_MODE_ENABLED) || false;
const ordersDataDir = "data";
const ordersDataFile = `${ordersDataDir}/orders.json`;

const DATE_FORMAT = "DD-MM-YYYY";
const CELLERY_USER_HEADER = "x-cellery-auth-subject";
const PET_STORE_GUEST_HEADER = "x-pet-store-guest";

const globalValidationOptions = {
    headers: {
        "content-type": joi.string().valid("application/json").insensitive().required(),
        "x-pet-store-guest": joi.string()
    }
};

fs.mkdirSync(ordersDataDir); // eslint-disable-line no-sync
fs.writeFileSync(ordersDataFile, "[]", "utf8"); // eslint-disable-line no-sync

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
 * Handle when the requested resource was not found.
 *
 * @param res The express response object
 * @param message The error message
 */
const handleNotFound = (res, message) => {
    res.status(404).send({
        status: "NOT_FOUND",
        message: message
    });
};

const orderSchema = {
    order: joi.array().items(joi.object({
        id: joi.number().integer().greater(0).required(),
        amount: joi.number().integer().greater(0).required()
    })).required()
};

/*
 * API endpoint for getting a list of orders available.
 */
service.get("/orders", (req, res) => {
    fs.readFile(ordersDataFile, "utf8", function (err, data) {
        const orders = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + ordersDataFile + " due to " + err);
        } else {
            const user = getUsername(req);
            const orderList = orders.filter((order) => order.customer === user);
            handleSuccess(res, orderList);
        }
    });
});

/*
 * API endpoint for creating a new order.
 */
const postOrderValidationOptions = {
    body: orderSchema,
    ...globalValidationOptions
};
service.post("/orders", validate(postOrderValidationOptions), (req, res) => {
    fs.readFile(ordersDataFile, "utf8", function (err, data) {
        const orders = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + ordersDataFile + " due to " + err);
        } else {
            // Creating the new order data
            const user = getUsername(req);
            const maxId = orders.reduce((acc, order) => order.id > acc ? order.id : acc, 0);
            orders.push({
                order: req.body.order.map((orderItem) => ({
                    id: orderItem.id,
                    amount: orderItem.amount
                })),
                customer: user,
                id: maxId + 1,
                orderDate: moment().format(DATE_FORMAT)
            });

            // Creating the new order
            fs.writeFile(ordersDataFile, JSON.stringify(orders), "utf8", function (err) {
                if (err) {
                    handleError(res, "Failed to create new order due to " + err)
                } else {
                    handleSuccess(res, {
                        id: maxId
                    });
                }
            });
        }
    });
});

/*
 * API endpoint for getting a single order.
 */
service.get("/orders/:id", (req, res) => {
    fs.readFile(ordersDataFile, "utf8", function (err, data) {
        const orders = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + ordersDataFile + " due to " + err);
        } else {
            const user = getUsername(req);
            let match = orders.filter((order) => order.id === req.params.id && order.customer === user);
            if (match.length === 1) {
                handleSuccess(res, match[0]);
            } else {
                handleNotFound("Order not available");
            }
        }
    });
});

/*
 * API endpoint for updating a order.
 */
const putOrderValidationOptions = {
    body: orderSchema,
    ...globalValidationOptions
};
service.put("/orders/:id", validate(putOrderValidationOptions), (req, res) => {
    fs.readFile(ordersDataFile, "utf8", function (err, data) {
        const orders = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + ordersDataFile + " due to " + err);
        } else {
            const user = getUsername(req);
            const match = orders.filter((order) => order.id === req.params.id && order.customer === user);

            if (match.length === 1) {
                Object.assign(match[0], {
                    order: req.body.order.map((orderItem) => ({
                        id: orderItem.id,
                        amount: orderItem.amount
                    }))
                });

                // Updating the order
                fs.writeFile(ordersDataFile, JSON.stringify(orders), "utf8", function (err) {
                    if (err) {
                        handleError(res, "Failed to update order " + req.params.id + " due to " + err)
                    } else {
                        handleSuccess(res);
                    }
                });
            } else {
                handleNotFound("Order not available");
            }
        }
    });
});

/*
 * API endpoint for deleting a order.
 */
service.delete("/orders/:id", (req, res) => {
    fs.readFile(ordersDataFile, "utf8", function (err, data) {
        const orders = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + ordersDataFile + " due to " + err);
        } else {
            const user = getUsername(req);
            const newOrders = orders.filter((order) => order.id !== req.params.id || order.customer !== user);

            if (newOrders.length === orders.length) {
                handleNotFound("Order not available");
            } else {
                // Deleting the order
                fs.writeFile(ordersDataFile, JSON.stringify(newOrders), "utf8", function (err) {
                    if (err) {
                        handleError(res, "Failed to delete order " + req.params.id + " due to " + err)
                    } else {
                        handleSuccess(res);
                    }
                });
            }
        }
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

    console.log("[INFO] Pet Store Orders Service listening at http://%s:%s", host, port);
});

// Listening for os Signals to gracefully shutdown
const shutdownServer = () => {
    console.log("[INFO] Shutting down Pet Store Orders Service");
    server.close(() => {
        console.log("[INFO] Pet Store Orders Service shutdown complete");
        // eslint-disable-next-line no-process-exit
        process.exit(0);
    });
};
process.on("SIGTERM", shutdownServer);
process.on("SIGINT", shutdownServer);
