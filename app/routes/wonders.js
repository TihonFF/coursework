const express = require("express");
const router = express.Router();
const wonderTable = require("../lib/db").Wonder; // путь к db.js
const wonderdb = require("../lib/db").db;

// Получить все чудеса
router.get("/wonders", function (req, res, next) {
  console.log("Показать информацию о всех чудесах света");
  wonderTable.all(function (err, wonders) {
    if (err) return next(err);
    res.json(wonders); // правильный JSON, без двойной сериализации
  });
});

// Получить чудо по id
router.get("/wonders/:id", function (req, res, next) {
  const id = req.params.id;
  console.log("Получить информацию о чуде по id = " + id);

  if (!wonderTable.find) {
    // если у Wonder нет метода find — используем all и фильтруем
    wonderTable.all(function (err, wonders) {
      if (err) return next(err);
      const wonder = wonders.find((w) => w.id == id);
      if (wonder) {
        res.json(wonder);
      } else {
        res.json({ message: "Нет чуда с id = " + id });
      }
    });
  } else {
    wonderTable.find(id, function (err, wonder) {
      if (err) return next(err);
      if (wonder) {
        res.json(wonder);
      } else {
        res.json({ message: "Нет чуда с id = " + id });
      }
    });
  }
});

// Добавить новое чудо
router.post("/wonders", function (req, res, next) {
  console.log("Добавление чуда света");

  const newWonder = {
    name: req.body.name,
    location: req.body.location,
    description: req.body.description,
    built: req.body.built,
  };

  console.log(newWonder);

  wonderTable.insert(newWonder, function (err, id) {
    if (err) return next(err);
    console.log("id = " + id);
    res.json({ id: id });
  });
});

// Обновить чудо
router.put("/wonders/:id", function (req, res, next) {
  const id = req.params.id;
  console.log("Обновление чуда. id = " + id);

  const updatedWonder = {
    id: id,
    name: req.body.name,
    location: req.body.location,
    description: req.body.description,
    built: req.body.built,
  };

  console.log(updatedWonder);

  wonderTable.update(updatedWonder, function (err) {
    if (err) return next(err);
    res.json({ message: "Данные успешно обновлены" });
  });
});

// Удалить чудо по id
router.delete("/wonders/:id", function (req, res, next) {
  const id = req.params.id;

  wonderTable.delete(id, function (err, msg) {
    if (err) return next(err);
    if (msg === "Нет чуда") {
      res.json({ message: "Нет чуда с id = " + id });
    } else {
      res.json({ message: "Удалено" });
    }
  });
});

// Закрытие БД при завершении приложения
process.on("SIGINT", () => {
  wonderdb.close();
});

module.exports = router;
