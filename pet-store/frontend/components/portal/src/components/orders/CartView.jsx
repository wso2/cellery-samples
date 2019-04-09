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

import Cart from "./cart";
import {Check} from "@material-ui/icons";
import Notification from "../common/Notification";
import React from "react";
import {withRouter} from "react-router-dom";
import withState from "../common/state";
import {withStyles} from "@material-ui/core/styles";
import {Button, Grid, Table, TableBody, TableCell, TableHead, TableRow, Typography} from "@material-ui/core";
import * as PropTypes from "prop-types";

const styles = (theme) => ({
    titleContent: {
        maxWidth: 600,
        margin: "0 auto",
        padding: `${theme.spacing.unit * 8}px 0 ${theme.spacing.unit * 6}px`
    },
    checkoutButton: {
        marginTop: theme.spacing.unit * 3
    }
});

class CartView extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            cartItems: props.cart.getItems(),
            notification: {
                open: false,
                message: ""
            }
        };
    }

    handleCheckout = () => {
        const self = this;
        const {cart, history} = this.props;
        cart.checkout()
            .then((response) => {
                self.setState({
                    cartItems: cart.getItems(),
                    notification: {
                        open: true,
                        message: `Order ${response.data.id} Placed`
                    }
                });
                history.push("/");
            })
            .catch(() => {
                self.setState({
                    notification: {
                        open: true,
                        message: "Failed to place order"
                    }
                });
            });
    };

    render() {
        const {classes} = this.props;
        const {cartItems, notification} = this.state;
        return (
            <Grid container justify={"center"}>
                <Grid item lg={8} md={10} xs={12} justify={"center"}>
                    <div className={classes.titleContent}>
                        <Typography component="h1" variant="h2" align="center" color="textPrimary" gutterBottom>
                            Cart
                        </Typography>
                    </div>
                    {
                        cartItems.length > 0
                            ? (
                                <React.Fragment>
                                    <Table>
                                        <TableHead>
                                            <TableRow>
                                                <TableCell align="right">Item ID</TableCell>
                                                <TableCell align="right">Amount</TableCell>
                                            </TableRow>
                                        </TableHead>
                                        <TableBody>
                                            {
                                                cartItems.map((cartItem) => (
                                                    <TableRow key={cartItem.id}>
                                                        <TableCell component="th" scope="row">
                                                            {cartItem.itemId}
                                                        </TableCell>
                                                        <TableCell align="right">{cartItem.amount}</TableCell>
                                                    </TableRow>
                                                ))
                                            }
                                        </TableBody>
                                    </Table>
                                    <Grid container direction={"row"} className={classes.checkoutButton}
                                        justify={"flex-end"} alignItems={"flex-end"}>
                                        <Button color={"primary"} variant={"contained"} size={"small"}
                                            onClick={this.handleCheckout}>
                                            <Check/> Checkout
                                        </Button>
                                    </Grid>
                                </React.Fragment>
                            )
                            : (
                                <Typography variant={"body1"} align={"center"} color={"textSecondary"}>
                                    Your Cart is empty
                                </Typography>
                            )
                    }
                    <Notification open={notification.open} onClose={this.handleNotificationClose}
                        message={notification.message}/>
                </Grid>
            </Grid>
        );
    }

}

CartView.propTypes = {
    classes: PropTypes.object.isRequired,
    cart: PropTypes.instanceOf(Cart).isRequired,
    history: PropTypes.shape({
        push: PropTypes.func.isRequired
    }).isRequired
};

export default withStyles(styles)(withState(withRouter(CartView)));
