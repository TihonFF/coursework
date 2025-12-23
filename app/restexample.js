const path = require("path");
const express = require("express");
const favicon = require("serve-favicon");
const indexRouter = require("./routes/index");
const apiRouter = require("./routes/api");

const app = express();

app.use(express.urlencoded({ extended: true }));

app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");
app.use(function (req, res, next) {
  console.log(req.method);
  console.log(req.url);
  console.log(req.headers);
  next();
});
app.use(favicon(path.join(__dirname, "public", "favicon.ico")));
app.use(express.static(path.join(__dirname, "public")));
app.use("/", indexRouter);
app.use("/api", apiRouter);
app.use(function (req, res) {
  res.type("text/plain");
  res.status(404);
  res.send("404 — Не найдено");
});
app.use(function (err, req, res, next) {
  console.log(err);
  res.type("text/plain");
  res.status(500);
  res.send("500 — Ошибка сервера");
});
app.listen(3000, function () {
  console.log("Сервер запущен на http://localhost:3000");
});
