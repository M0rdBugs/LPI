<?php
    class Database {
        private static $conn;

        public static function connect() {
            if (!self::$conn) {
                self::$conn = new mysqli("localhost", "root", "", "FelixUberShop");
                if (self::$conn->connect_error) {
                    die("Conecção falhou: " . self::$conn->connect_error);
                }
            }
            return self::$conn;
        }
    }
?>