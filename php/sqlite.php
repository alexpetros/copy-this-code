/*
 * A simple setup for PDO and SQLite.
 * Courtesy of Nathaniel Sabanski, with permission
 */
<?php
function db_connect($file) {
    try {
        $db = new PDO($file, '', '', [PDO::ATTR_EMULATE_PREPARES => false, PDO::ATTR_PERSISTENT => false,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, ]);
        $db->exec('PRAGMA journal_mode = wal2;');
        $db->exec('PRAGMA synchronous = normal;');
        $db->exec('PRAGMA temp_store = memory;');
        # Allow caching of 10000 pages (10000 * 4096 = 40 megabytes)
        $db->exec('PRAGMA cache_size = 10000;');
    }
    catch(PDOException $e) {
        die("Could not connect to database.");
    }
    return $db;
}
function db_query($db, $sql, $params=[]) {
    try {
        $result = null;
        $db->exec('BEGIN;');
        $statement = $db->prepare($sql);
        $db->exec('COMMIT;');
        $statement->execute($params);
        $result = $statement->fetchall();
        if ($result == false) {
            return [];
        }
        return $result;
    }
    catch(Exception $e) {
        file_put_contents("./error.txt", $e, FILE_APPEND);
        http_response_code(500);
        die();
    }
}
?>
