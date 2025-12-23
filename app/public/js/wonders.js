$(document).ready(function () {
  $("#search").click(function () {
    $.ajax({
      url: "/api/wonders",
      type: "GET",
      dataType: "json",
      success: function (data) {
        renderTable(data);
      },
      error: function () {
        alert("Ошибка загрузки данных");
      },
    });
  });

  $("#select").click(function () {
    let id = $("#select_id").val();
    if (!id) return alert("Введите ID");

    $.ajax({
      url: "/api/wonders/" + id,
      type: "GET",
      dataType: "json",
      success: function (data) {
        if (data.message) return alert(data.message);

        $("#w_id").text(data.id);
        $("#wonder_form [name='name']").val(data.name);
        $("#wonder_form [name='location']").val(data.location);
        $("#wonder_form [name='description']").val(data.description);
        $("#wonder_form [name='built']").val(data.built);
      },
    });
  });

  $("#new").click(function () {
    $("#w_id").text("0");
    $("#wonder_form input[type='text']").val("");
  });

  $("#add").click(function () {
    let currentId = $("#w_id").text().trim();
    if (currentId === "") {
      $("#w_id").text("0");
      currentId = "0";
    }
    if (currentId !== "0") return alert("Нажмите 'Новый' перед созданием");

    $.ajax({
      url: "/api/wonders",
      type: "POST",
      data: $("#wonder_form").serialize(),
      dataType: "json",
      success: function (data) {
        $("#w_id").text(data.id);
      },
      error: function () {
        alert("Ошибка добавления");
      },
    });
  });

  $("#update").click(function () {
    let id = $("#w_id").text();
    if (id === "0") return alert("Выберите запись");

    $.ajax({
      url: "/api/wonders/" + id,
      type: "PUT",
      data: $("#wonder_form").serialize(),
      dataType: "json",
      success: function () {
        alert("Обновлено");
      },
    });
  });

  $("#delete").click(function () {
    let id = $("#select_id").val();
    if (!id) return alert("Введите ID");

    $.ajax({
      url: "/api/wonders/" + id,
      type: "DELETE",
      dataType: "json",
      success: function (data) {
        alert(data.message);
      },
    });
  });
});

function renderTable(data) {
  let html = `<table>
      <tr>
        <th>ID</th>
        <th>Название</th>
        <th>Локация</th>
        <th>Описание</th>
        <th>Построено</th>
      </tr>`;

  data.forEach((w) => {
    html += `
      <tr>
        <td>${w.id}</td>
        <td>${w.name}</td>
        <td>${w.location}</td>
        <td>${w.description}</td>
        <td>${w.built}</td>
      </tr>`;
  });

  html += "</table>";

  $("#wonder_list").html(html);
}
