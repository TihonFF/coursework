// Использование модуля базы данных SQLite
const sqlite3 = require("sqlite3").verbose();

// Имя файла базы данных. Файл создается в корневой папке
const dbName = "sqlitedb.db";

// Подключение к базе данных
const db = new sqlite3.Database(dbName, function (err) {
  if (err) {
    return console.error(err.message);
  }
  console.log("Подключение к базе данных SQLite");
});

// Создание таблицы wonders
db.serialize(function () {
  console.log("Создание таблицы wonders, если её не существует");
  const sql = `
    CREATE TABLE IF NOT EXISTS wonders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      location TEXT,
      description TEXT,
      built TEXT
    )
  `;
  db.run(sql);
});

class Wonder {
  // Выбор всех чудес
  static all(cb) {
    db.all("SELECT id, name, location, description, built FROM wonders", cb);
  }

  // Выбор чуда по id
  static find(id, cb) {
    db.get(
      `
      SELECT id, name, location, description, built
      FROM wonders WHERE id = ?
    `,
      id,
      cb
    );
  }

  // Добавление нового чуда
  static insert(data, cb) {
    const sql = `
      INSERT INTO wonders (name, location, description, built)
      VALUES (?, ?, ?, ?)
    `;
    db.run(
      sql,
      data.name,
      data.location,
      data.description,
      data.built,
      function (err) {
        if (err) {
          console.log(err);
          return cb(err);
        } else {
          console.log("new id = " + this.lastID);
          return cb(err, this.lastID);
        }
      }
    );
  }

  // Обновление чуда
  static update(data, cb) {
    const sql = `
      UPDATE wonders
      SET name = ?, location = ?, description = ?, built = ?
      WHERE id = ?
    `;
    db.run(
      sql,
      data.name,
      data.location,
      data.description,
      data.built,
      data.id,
      function (err) {
        if (err) {
          console.log(err);
        }
        return cb(err);
      }
    );
  }

  // Удаление по id
  static delete(id, cb) {
    db.get(
      "SELECT id FROM wonders WHERE id = ?",
      id,
      function (err, wonder_id) {
        if (err) return cb(err);

        if (wonder_id) {
          db.run("DELETE FROM wonders WHERE id = ?", id, function (err) {
            if (err) return cb(err);
            cb(null, "Удалено");
          });
        } else {
          return cb(null, "Нет чуда");
        }
      }
    );
  }
}

// Экспорт
module.exports = db;
module.exports.Wonder = Wonder;
