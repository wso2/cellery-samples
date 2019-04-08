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

/* eslint react/prefer-stateless-function: ["off"] */

import Cart from "./cart";
import React from "react";
import * as PropTypes from "prop-types";

// Creating a context that can be accessed
const CartContext = React.createContext({});

const CartProvider = ({children}) => (
    <CartContext.Provider value={new Cart()}>
        {children}
    </CartContext.Provider>
);

CartProvider.propTypes = {
    children: PropTypes.any.isRequired
};

/**
 * Higher Order Component for accessing the Cart.
 *
 * @param {React.ComponentType} Component component which needs access to the cart.
 * @returns {React.ComponentType} The new HOC with access to the cart.
 */
const withCart = (Component) => {
    class CartConsumer extends React.Component {

        render = () => {
            const {forwardedRef, ...otherProps} = this.props;

            return (
                <CartContext.Consumer>
                    {(cart) => <Component cart={cart} ref={forwardedRef} {...otherProps}/>}
                </CartContext.Consumer>
            );
        };

    }

    CartConsumer.propTypes = {
        forwardedRef: PropTypes.any
    };

    return React.forwardRef((props, ref) => <CartConsumer {...props} forwardedRef={ref} />);
};

export default withCart;
export {CartProvider};
