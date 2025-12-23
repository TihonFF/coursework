const express = require("express");
const app = express();
app.get("/", function (req, res, next) {
  res.type("text/plain");
  res.send("Hello world");
});
app.use(function (req, res) {
  res.type("text/plain");
  res.status(404);
  res.send("404 — Не найдено");
});
app.listen(3000, function () {
  console.log("Сервер запущен на http://localhost:3000");
});
