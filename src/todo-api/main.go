/*
 * Copyright (c) 2018 WSO2 Inc. (http:www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http:www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gorilla/mux"

	//"strconv"
	"strings"
)

const (
	// Env variables
	Port                      = "PORT"
	Database_Host             = "DATABASE_HOST"
	Database_Port             = "DATABASE_PORT"
	Database_Credentials_Path = "DATABASE_CREDENTIALS_PATH"
	Database_Name             = "DATABASE_NAME"
)

var env = loadEnv(Port, Database_Host, Database_Port, Database_Credentials_Path, Database_Name)

type Todo struct {
	ID      int    `json:"id"`
	Title   string `json:"title"`
	Content string `json:"content"`
	Done    bool   `json:"done"`
}

var db *sql.DB

func CreateTodo(w http.ResponseWriter, r *http.Request) {
	var todo Todo
	json.NewDecoder(r.Body).Decode(&todo)

	query, err := db.Prepare("INSERT todos SET title=?, content=?, done=?")
	if err != nil {
		makeInternalErrorResponse(w, err)
		return
	}

	_, err = query.Exec(todo.Title, todo.Content, todo.Done)
	if err != nil {
		makeInternalErrorResponse(w, err)
		return
	}
	defer query.Close()

	makeCreatedResponse(w, map[string]string{"message": "successfully created"})

}

func UpdateTodo(w http.ResponseWriter, r *http.Request) {
	var todo Todo
	params := mux.Vars(r)
	id := params["id"]
	json.NewDecoder(r.Body).Decode(&todo)

	query, err := db.Prepare("UPDATE todos SET title=?, content=?, done=? WHERE id=?")
	if err != nil {
		makeInternalErrorResponse(w, err)
		return
	}
	_, err = query.Exec(todo.Title, todo.Content, todo.Done, id)
	if err != nil {
		makeInternalErrorResponse(w, err)
		return
	}
	defer query.Close()

	makeOkResponse(w, map[string]string{"message": "successfully updated"})
}

func GetTodo(w http.ResponseWriter, r *http.Request) {
	todo := Todo{}
	params := mux.Vars(r)
	id := params["id"]
	row := db.QueryRow("SELECT id, title, content, done FROM todos WHERE id=?", id)
	err := row.Scan(
		&todo.ID,
		&todo.Title,
		&todo.Content,
		&todo.Done,
	)
	if err != nil {
		makeInternalErrorResponse(w, err)
		return
	}
	makeOkResponse(w, todo)
}

func GetTodos(w http.ResponseWriter, r *http.Request) {
	var errors []error
	var todos []Todo

	rows, err := db.Query("SELECT id, title, content, done FROM todos")
	if err != nil {
		makeInternalErrorResponse(w, err)
		return
	}
	defer rows.Close()

	for rows.Next() {
		data := Todo{}
		er := rows.Scan(&data.ID, &data.Title, &data.Content, &data.Done)
		if er != nil {
			errors = append(errors, er)
		}
		todos = append(todos, data)
	}

	if len(errors) > 0 {
		makeInternalErrorResponse(w, errors...)
		return
	}
	makeOkResponse(w, todos)
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/todos", GetTodos).Methods("GET")
	router.HandleFunc("/todos/{id}", GetTodo).Methods("GET")
	router.HandleFunc("/todos", CreateTodo).Methods("POST")
	router.HandleFunc("/todos/{id}", UpdateTodo).Methods("PUT")
	fatal(http.ListenAndServe(":"+env[Port], router))
}

func loadEnv(keys ...string) map[string]string {
	m := make(map[string]string)
	var emptyKeys []string
	for _, key := range keys {
		value := os.Getenv(key)
		if len(value) == 0 {
			emptyKeys = append(emptyKeys, key)
		}
		m[key] = value
	}
	if len(emptyKeys) != 0 {
		fatal(fmt.Errorf("Missing required enviroment varibles %q\n", strings.Join(emptyKeys, ",")))
	}
	log.Println("Environment variables")
	for k, v := range m {
		log.Printf("%s=%s", k, v)
	}
	return m
}

func init() {
	var err error

	usernameBytes, err := ioutil.ReadFile(filepath.Join(env[Database_Credentials_Path], "username"))
	fatal(err)
	passwordBytes, err := ioutil.ReadFile(filepath.Join(env[Database_Credentials_Path], "password"))
	fatal(err)

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?autocommit=true",
		strings.TrimSuffix(string(usernameBytes), "\n"),
		strings.TrimSuffix(string(passwordBytes), "\n"),
		env[Database_Host],
		env[Database_Port],
		env[Database_Name],
	)
	db, err = sql.Open("mysql", dsn)
	fatal(err)
}

func fatal(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func makeInternalErrorResponse(w http.ResponseWriter, errs ...error) {
	makeErrorResponse(w, http.StatusInternalServerError, errs...)
}

func makeErrorResponse(w http.ResponseWriter, statusCode int, errs ...error) {
	m := make(map[string][]string)
	var strErrs []string
	for _, err := range errs {
		strErrs = append(strErrs, err.Error())
	}
	m["error"] = strErrs
	makeResponse(w, statusCode, m)
}

func makeCreatedResponse(w http.ResponseWriter, v interface{}) {
	makeResponse(w, http.StatusCreated, v)
}

func makeOkResponse(w http.ResponseWriter, v interface{}) {
	makeResponse(w, http.StatusOK, v)
}

func makeResponse(w http.ResponseWriter, statusCode int, v interface{}) {
	w.WriteHeader(statusCode)
	e := json.NewEncoder(w)
	e.SetIndent("", "  ")
	e.Encode(v)
}
