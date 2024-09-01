<?php
function redirect($path) {
  header("Location: $path");
  die();
}

function db_connect($file) {
  try {
    $db = new PDO("sqlite:$file", '', '');
  }
  catch(PDOException $e) {
    error_log(var_dump($e));
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
    error_log(var_dump($e));
    http_response_code(500);
    die();
  }
}

$db = db_connect('../questions.db');
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Router
if (str_starts_with($path, '/packets')) {
  include('./packets.php');
  die();
}
?>

