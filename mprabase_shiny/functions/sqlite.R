openDatabaseConnection <- function() {
  tryCatch({
    print_stderr(sprintf("Trying to connect to database: %s", SQLITE_DB))
    DB_CONNECTION <<- DBI::dbConnect(
      RSQLite::SQLite(), SQLITE_DB
    )
    print_stderr("Connection established.")
  }, error = function(e) {
    print_stderr(sprintf("Connection error: %s", e))
  }
  )
}

closeDatabaseConnection <- function() {
  tryCatch({
    DBI::dbDisconnect(DB_CONNECTION)
    print_stderr("Database disconnected.")
  }, error = function(e) {
    print_stderr(sprintf("Disconnecting error: %s", e))
  }, finally = function() {
    DB_CONNECTION <<- NULL
  }
  )
}

executeQuery <- function(query) {
  tryCatch({
    queryResult <- data.table::as.data.table(
      DBI::dbGetQuery(DB_CONNECTION, query)
    )
    return(queryResult)
  }, error = function(e) {
    print_stderr(sprintf("DB query error: %s", e))
    return(NULL)
  }
  )
}

alterDB <- function(sql_code) {
  tryCatch({
    DBI::dbExecute(DB_CONNECTION, sql_code)
  }, error = function(e) {
    print_stderr(sprintf("DB SQL execution code error: %s", e))
    return(NULL)
  }
  )
}



checkIndexing <- function() {
  sql <- "
SELECT DISTINCT sqlite_master.name AS `table`, indexes.name AS `indexed_column` 
  FROM sqlite_master, 
       pragma_index_list(sqlite_master.name) AS index_left,
       pragma_index_info(index_left.name) AS indexes
 WHERE sqlite_master.type = 'table';
  "
  indexes <- executeQuery(sql)
  lapply(names(COLUMNS_TO_INDEX), function(table) {
    indexed <- indexes[indexes$table == table,]$indexed_column
    lapply(COLUMNS_TO_INDEX[[table]], function(col) {
      if(col %in% indexed) {
        print_stderr(sprintf("INDEX %s_%s exists...OK", table, col))
      }
      else {
        sql <- sprintf("CREATE INDEX %s_%s ON %s(%s);", table, col, table, col)
        print_stderr(sprintf("Create index: %s", sql))
        alterDB(sql)
      }
    })
    
  })
}