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

import Catalog from "./Catalog";
import Orders from "./Orders";
import React from "react";
import SignIn from "./user/SignIn";
import SignUp from "./user/SignUp";
import {withStyles} from "@material-ui/core/styles";
import {AccountCircle, Pets} from "@material-ui/icons";
import {AppBar, Avatar, Button, IconButton, Menu, MenuItem, Toolbar, Typography} from "@material-ui/core";
import {Redirect, Route, Switch, withRouter} from "react-router-dom";
import * as PropTypes from "prop-types";

const styles = (theme) => ({
    appBar: {
        position: "relative"
    },
    logo: {
        marginRight: theme.spacing.unit * 2
    },
    title: {
        flexGrow: 1
    },
    userAvatarContainer: {
        marginBottom: theme.spacing.unit * 2,
        pointerEvents: "none"
    },
    userAvatar: {
        marginRight: theme.spacing.unit * 1.5,
        color: "#fff",
        backgroundColor: theme.palette.primary.main
    }
});

class App extends React.Component {

    constructor(props) {
        super(props);

        this.state = {
            accountPopoverElement: null
        };
    }

    handleAccountPopoverOpen = (event) => {
        this.setState({
            accountPopoverElement: event.currentTarget
        });
    };

    handleAccountPopoverClose = () => {
        this.setState({
            accountPopoverElement: null
        });
    };

    signIn = () => {
        window.location.href = `${window.__BASE_PATH__}/sign-in`;
    };

    signOut = () => {
        window.location.href = `${window.__BASE_PATH__}/_auth/logout`;
    };

    render() {
        const {classes, initialState} = this.props;
        const {accountPopoverElement} = this.state;
        const isAccountPopoverOpen = Boolean(accountPopoverElement);

        return (
            <div className={classes.root}>
                <AppBar position="static" className={classes.appBar}>
                    <Toolbar>
                        <Pets className={classes.logo}/>
                        <Typography variant="h6" color="inherit" noWrap className={classes.title}>
                            Pet Store
                        </Typography>
                        {
                            initialState.user
                                ? (
                                    <div>
                                        <IconButton
                                            aria-owns={isAccountPopoverOpen ? "user-info-appbar" : undefined}
                                            color="inherit" aria-haspopup="true"
                                            onClick={this.handleAccountPopoverOpen}>
                                            <AccountCircle/>
                                        </IconButton>
                                        <Menu id="user-info-appbar" anchorEl={accountPopoverElement}
                                            anchorOrigin={{
                                                vertical: "top",
                                                horizontal: "right"
                                            }}
                                            transformOrigin={{
                                                vertical: "top",
                                                horizontal: "right"
                                            }}
                                            open={isAccountPopoverOpen}
                                            onClose={this.handleAccountPopoverClose}>
                                            <MenuItem onClick={this.handleAccountPopoverClose}
                                                className={classes.userAvatarContainer}>
                                                <Avatar className={classes.userAvatar}>
                                                    {initialState.user.substr(0, 1).toUpperCase()}
                                                </Avatar>
                                                {initialState.user}
                                            </MenuItem>
                                            <MenuItem onClick={this.signOut}>
                                                Sign Out
                                            </MenuItem>
                                        </Menu>
                                    </div>
                                )
                                : (
                                    <Button style={{color: "#ffffff"}} onClick={this.signIn}>Sign In</Button>
                                )
                        }
                    </Toolbar>
                </AppBar>
                <main>
                    <Switch>
                        <Route exact path={"/"} render={() => <Catalog catalog={initialState.catalog}
                            user={initialState.user}/>}/>
                        <Route exact path={"/sign-in"} component={SignIn}/>
                        <Route exact path={"/sign-up"} component={SignUp}/>
                        {
                            initialState.user
                                ? <Route exact path={"/orders"} component={Orders}/>
                                : null
                        }
                        <Redirect from={"*"} to={"/"}/>
                    </Switch>
                </main>
            </div>
        );
    }

}

App.propTypes = {
    classes: PropTypes.string.isRequired,
    initialState: PropTypes.shape({
        catalog: PropTypes.object
    }).isRequired
};

export default withStyles(styles)(withRouter(App));
