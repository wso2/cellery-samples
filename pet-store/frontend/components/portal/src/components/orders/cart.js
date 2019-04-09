/*
 * Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import * as utils from "../../utils";

/**
 * Instance of the shopping cart of the current user.
 */
class Cart {

    /**
     * @private
     */
    items = [];

    /**
     * Add an item to the cart.
     *
     * @param {number} itemId The ID of the item
     * @param {number} amount The amount of items to be purchased
     * @returns {number} The cart item ID
     */
    addItem(itemId, amount) {
        const id = this.items.reduce((acc, cartItem) => (cartItem.id > acc ? cartItem.id : acc), 0) + 1;
        this.items.push({
            id: id,
            itemId: itemId,
            amount: amount
        });
        return id;
    }

    /**
     * Remove an item from the cart.
     *
     * @param {number} id The ID of the cart item to be removed
     */
    removeItem(id) {
        const cartItemIndex = this.items.indexOf((cartItem) => cartItem.id === id);
        this.items.splice(cartItemIndex, 1);
    }

    /**
     * Get the current Cart of the user.
     *
     * @returns {Array<{id: number, itemId: number, amount: number}>} The items array in the cart.
     */
    getItems() {
        return [...this.items];
    }

    /**
     * Checkout the cart and place an order.
     *
     * @returns {Promise} Promise for resolve/reject upon checkout
     */
    checkout() {
        const self = this;
        const config = {
            url: "/orders",
            method: "POST",
            data: {
                order: self.items.map((cartItem) => ({
                    id: cartItem.itemId,
                    amount: cartItem.amount
                }))
            }
        };
        return new Promise((resolve, reject) => {
            utils.callApi(config)
                .then((data) => {
                    self.items = [];
                    resolve(data);
                })
                .catch((error) => {
                    reject(error);
                });
        });
    }

}

export default Cart;
