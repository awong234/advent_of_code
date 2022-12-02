var doc = document.getElementById("day-links")
// var day_names = []

for (let i = 1; i <= 25; i++) {
    var a = document.createElement('a')
    var index = String(i).padStart(2, '0')
    var day_num = "Day_" + index
    var path = "./day_" + index
    var link = document.createTextNode(day_num)
    a.appendChild(link)
    a.title = day_num
    a.href = path
    doc.appendChild(a)
    doc.appendChild(document.createElement("br"))
}
