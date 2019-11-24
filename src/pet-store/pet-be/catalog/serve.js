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
const morgan = require("morgan");
const path = require("path");
const rotatingFileStream = require("rotating-file-stream");
const validate = require("express-validation");
const joi = require("joi");

const service = express();
const port = process.env.SERVICE_PORT || 3001;
const catalogDataFile = "data/catalog.json";

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

const accessorySchema = {
    name: joi.string().required(),
    description: joi.string().required(),
    unitPrice: joi.number().greater(0).precision(2).required(),
    inStock: joi.number().integer().min(0).required()
};

/*
 * API endpoint for getting a list of accessories available in the catalog.
 */
service.get("/accessories", (req, res) => {
    fs.readFile(catalogDataFile, "utf8", function (err, data) {
        if (err) {
            handleError(res, "Failed to read data file " + catalogDataFile + " due to " + err);
        } else {
            handleSuccess(res, JSON.parse(data));
        }
    });
});

/*
 * API endpoint for creating a new accessory in the catalog.
 */
const postAccessoryValidationOptions = {
    body: accessorySchema,
    ...globalValidationOptions
};
service.post("/accessories", validate(postAccessoryValidationOptions), (req, res) => {
    fs.readFile(catalogDataFile, "utf8", function (err, data) {
        const accessories = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + catalogDataFile + " due to " + err);
        } else {
            // Creating the new accessory data.
            const maxId = accessories.reduce((acc, accessory) => accessory.id > acc ? accessory.id : acc, 0);
            accessories.push({
                id: maxId + 1,
                name: req.body.name,
                description: req.body.description,
                unitPrice: req.body.unitPrice,
                inStock: req.body.inStock
            });

            // Creating the new accessory
            fs.writeFile(catalogDataFile, JSON.stringify(accessories), "utf8", function (err) {
                if (err) {
                    handleError(res, "Failed to create new accessory due to " + err)
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
 * API endpoint for getting a single accessory from the catalog.
 */
service.get("/accessories/:id", (req, res) => {
    fs.readFile(catalogDataFile, "utf8", function (err, data) {
        const accessories = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + catalogDataFile + " due to " + err);
        } else {
            let match = accessories.filter((accessory) => accessory.id === req.params.id);
            if (match.length === 1) {
                handleSuccess(res, match[0]);
            } else {
                handleNotFound("Accessory not available");
            }
        }
    });
});

/*
 * API endpoint for updating an accessory in the catalog.
 */
const putAccessoryValidationOptions = {
    body: accessorySchema,
    ...globalValidationOptions
};
service.put("/accessories/:id", validate(putAccessoryValidationOptions), (req, res) => {
    fs.readFile(catalogDataFile, "utf8", function (err, data) {
        const accessories = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + catalogDataFile + " due to " + err);
        } else {
            const match = accessories.filter((accessory) => accessory.id === req.params.id);

            if (match.length === 1) {
                Object.assign(match[0], {
                    name: req.body.name,
                    description: req.body.description,
                    unitPrice: req.body.unitPrice,
                    inStock: req.body.inStock
                });

                // Updating the accessory
                fs.writeFile(catalogDataFile, JSON.stringify(accessories), "utf8", function (err) {
                    if (err) {
                        handleError(res, "Failed to update accessory " + req.params.id + " due to " + err)
                    } else {
                        handleSuccess(res);
                    }
                });
            } else {
                handleNotFound("Accessory not available");
            }
        }
    });
});

/*
 * API endpoint for deleting an accessory in the catalog.
 */
service.delete("/accessories/:id", (req, res) => {
    fs.readFile(catalogDataFile, "utf8", function (err, data) {
        const accessories = JSON.parse(data);
        if (err) {
            handleError(res, "Failed to read data file " + catalogDataFile + " due to " + err);
        } else {
            const newAccessories = accessories.filter((accessory) => accessory.id !== req.params.id);

            if (newAccessories.length === accessories.length) {
                handleNotFound("Accessory not available");
            } else {
                // Deleting the accessory
                fs.writeFile(catalogDataFile, JSON.stringify(newAccessories), "utf8", function (err) {
                    if (err) {
                        handleError(res, "Failed to delete accessory " + req.params.id + " due to " + err)
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

    console.log("[INFO] Pet Store Catalog Service listening at http://%s:%s", host, port);
});

// Listening for os Signals to gracefully shutdown
const shutdownServer = () => {
    console.log("[INFO] Shutting down Pet Store Catalog Service");
    server.close(() => {
        console.log("[INFO] Pet Store Catalog Service shutdown complete");
        // eslint-disable-next-line no-process-exit
        process.exit(0);
    });
};
process.on("SIGTERM", shutdownServer);
process.on("SIGINT", shutdownServer);
