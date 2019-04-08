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
import React from "react";
import withCart from "./context";
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
    handleCheckout = () => {
        const {cart} = this.props;
        cart.checkout();
    };

    render() {
        const {cart, classes} = this.props;
        return (
            <Grid container justify={"center"}>
                <Grid item lg={8} md={10} xs={12} justify={"center"}>
                    <div className={classes.titleContent}>
                        <Typography component="h1" variant="h2" align="center" color="textPrimary" gutterBottom>
                            Cart
                        </Typography>
                    </div>
                    {
                        cart.getItems().length > 0
                            ? (
                                <React.Fragment>
                                    <Table>
                                        <TableHead>
                                            <TableRow>
                                                <TableCell align="right">Item</TableCell>
                                                <TableCell align="right">Amount</TableCell>
                                                <TableCell align="right">Price</TableCell>
                                            </TableRow>
                                        </TableHead>
                                        <TableBody>
                                            {
                                                cart.getItems().map((cartItem) => (
                                                    <TableRow key={cartItem.id}>
                                                        <TableCell component="th" scope="row">{cartItem.itemId}</TableCell>
                                                        <TableCell align="right">{cartItem.itemId}</TableCell>
                                                        <TableCell align="right">{cartItem.amount}</TableCell>
                                                    </TableRow>
                                                ))
                                            }
                                        </TableBody>
                                    </Table>
                                    <Grid container direction={"row"} className={classes.checkoutButton}
                                          justify={"flex-end"} alignItems={"flex-end"}>
                                        <Button color={"primary"} variant={"contained"}
                                                size={"small"} onClick={this.handleCheckout()}>
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
                </Grid>
            </Grid>
        );
    }

}

CartView.propTypes = {
    classes: PropTypes.object.isRequired,
    cart: PropTypes.instanceOf(Cart).isRequired
};

export default withStyles(styles)(withCart(CartView));
