package main

import (
	"database/sql"
	"fmt"
	"net/http"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	http.HandleFunc("/mysql", handler)
	http.HandleFunc("/hello", hello)
	http.ListenAndServe(":8080", nil)
}

func hello(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("hello"))
}

func handler(w http.ResponseWriter, r *http.Request) {
	db, err := sql.Open("mysql", "root@/sample")
	if err != nil {
		fmt.Println("can not connect")
		panic(err)
		//w.WriteHeader(http.StatusServiceUnavailable)
		//w.Write([]byte(err.Error()))
		//return
	}

	defer db.Close()

	rows, err := db.Query("SELECT * FROM users")
	defer rows.Close()
	if err != nil {
		fmt.Println("can not connect users tables")
		panic(err)
		//w.WriteHeader(http.StatusServiceUnavailable)
		//w.Write([]byte(err.Error()))
		//return
	}

	for rows.Next() {
		var id int
		var name string
		if err := rows.Scan(&id, &name); err != nil {
			w.WriteHeader(http.StatusServiceUnavailable)
			w.Write([]byte(err.Error()))
			return
		}
		fmt.Println(id, name)
		//TODO
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(name))
		return
	}
}
