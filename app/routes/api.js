const express = require("express");
const router = express.Router();
const wonderTable = require("../lib/db").Wonder;
const wonderdb = require("../lib/db").db;

// Получить все чудеса
router.get("/wonders", function (req, res, next) {
  console.log("Показать информацию о всех чудесах света");
  wonderTable.all(function (err, wonders) {
    if (err) return next(err);
    res.json(JSON.stringify(wonders));
  });
});

// Получить чудо по id
router.get("/wonders/:id", function (req, res, next) {
  const id = req.params.id;
  console.log("Получить информацию о чуде по id = " + id);
  wonderTable.find(id, function (err, wonder) {
    if (err) return next(err);
    if (wonder) {
      res.json(JSON.stringify(wonder));
    } else {
      res.json(JSON.stringify({ message: "Нет чуда с id = " + id }));
    }
  });
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

  console.log(
    newWonder.name +
      " " +
      newWonder.location +
      " " +
      newWonder.description +
      " " +
      newWonder.built
  );

  wonderTable.insert(newWonder, function (err, id) {
    if (err) return next(err);
    console.log("id = " + id);

    res.json(JSON.stringify({ id: id }));
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

  console.log(
    updatedWonder.id +
      " " +
      updatedWonder.name +
      " " +
      updatedWonder.location +
      " " +
      updatedWonder.description +
      " " +
      updatedWonder.built
  );

  wonderTable.update(updatedWonder, function (err) {
    if (err) return next(err);

    res.json(JSON.stringify({ message: "Данные успешно обновлены" }));
  });
});

// Удалить чудо по id
router.delete("/wonders/:id", function (req, res, next) {
  const id = req.params.id;

  wonderTable.delete(id, function (err, msg) {
    if (err) return next(err);
    if (msg == "Нет чуда") {
      res.json(JSON.stringify({ message: "Нет чуда с id = " + id }));
    } else {
      res.json(JSON.stringify({ message: "Удалено" }));
    }
  });
});

// Закрытие бд при завершении
process.on("SIGINT", () => {
  wonderdb.close();
});

module.exports = router;
