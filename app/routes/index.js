var express = require("express");
var router = express.Router();

/* Главная страница — отображение UI */
router.get("/", function (req, res) {
  res.render("index", { title: "Чудеса света" });
});

module.exports = router;
