//После загрузки страницы определить обработчик нажатия кнопки
$(document).ready(function () {
  // === Получить все чудеса ===
  $("#search").click(function () {
    $.ajax({
      url: "/api/wonders",
      type: "GET",
      dataType: "json",
      success: function (response) {
        data = $.parseJSON(response);

        var str = "";
        str += "<table>" + "<caption>Список чудес света</caption>";
        str +=
          "<tr>" +
          "<th>ID</th>" +
          "<th>Название</th>" +
          "<th>Местоположение</th>" +
          "<th>Описание</th>" +
          "<th>Построено</th>" +
          "</tr>";

        for (var i in data) {
          str +=
            "<tr>" +
            "<td>" +
            data[i]["id"] +
            "</td>" +
            "<td>" +
            data[i]["name"] +
            "</td>" +
            "<td>" +
            data[i]["location"] +
            "</td>" +
            "<td>" +
            data[i]["description"] +
            "</td>" +
            "<td>" +
            data[i]["built"] +
            "</td>" +
            "</tr>";
        }

        str += "</table>";
        $("#wonder_list").html(str); // НОВЫЙ div
      },
      error: function () {
        alert("Данные не получены");
      },
    });
  });

  // === Найти по ID ===
  $("#select").click(function () {
    var id = $("#select_id").val();
    if (!id || id == "0") {
      alert("Укажите идентификатор чуда");
      return false;
    }

    $.ajax({
      url: "/api/wonders/" + id,
      type: "GET",
      dataType: "json",
      success: function (response) {
        data = $.parseJSON(response);

        if (data.message) {
          alert(data.message);
        } else {
          $("#wnd_id").html(data["id"]);
          $("#wonder_form").find("input[name='name']").val(data["name"]);
          $("#wonder_form")
            .find("input[name='location']")
            .val(data["location"]);
          $("#wonder_form")
            .find("textarea[name='description']")
            .val(data["description"]);
          $("#wonder_form").find("input[name='built']").val(data["built"]);
        }
      },
      error: function () {
        alert("Данные не получены");
      },
    });
  });

  // === Новая запись ===
  $("#new").click(function () {
    $("#wnd_id").html("0");
    $("#wonder_form").find("input[name='name']").val("");
    $("#wonder_form").find("input[name='location']").val("");
    $("#wonder_form").find("textarea[name='description']").val("");
    $("#wonder_form").find("input[name='built']").val("");
  });

  // === Добавить новую запись ===
  $("#add").click(function () {
    if ($("#wnd_id").html() != "0") {
      alert('Нажмите кнопку "Новое чудо" перед добавлением');
      return false;
    }

    var formData = $("#wonder_form").serialize();

    $.ajax({
      url: "/api/wonders",
      type: "POST",
      dataType: "json",
      data: formData,
      success: function (response) {
        data = $.parseJSON(response);
        $("#wnd_id").html(data["id"]);
      },
      error: function () {
        alert("Ошибка при добавлении");
      },
    });
  });

  // === Обновить чудо ===
  $("#update").click(function () {
    var id = $("#wnd_id").html();
    if (!id || id == "0") {
      alert("Сначала выберите чудо");
      return false;
    }

    var formData = $("#wonder_form").serialize();

    $.ajax({
      url: "/api/wonders/" + id,
      type: "PUT",
      dataType: "json",
      data: formData,
      success: function () {
        alert("Данные обновлены");
      },
      error: function () {
        alert("Ошибка при обновлении");
      },
    });
  });

  // === Удалить по ID ===
  $("#delete").click(function () {
    var id = $("#select_id").val();
    if (!id || id == "0") {
      alert("Укажите идентификатор чуда");
      return false;
    }

    $.ajax({
      url: "/api/wonders/" + id,
      type: "DELETE",
      dataType: "json",
      success: function (response) {
        data = $.parseJSON(response);
        alert(data["message"]);
      },
      error: function () {
        alert("Ошибка при удалении");
      },
    });
  });
});
