
# Создание zmp с типичными параметрами URL

В предыдущих версиях SAS.Planet, чтобы добавить [zmp](zmp.md) с новой картой, нужно было немного откорректировать скрипт из файла [GetUrlScript.txt](zmp-geturlscript-txt.md), написанный на языке Pascal. Такой способ универсален, но трудоёмок, хотя является порой единственным способом добавления нестандартной карты.

Теперь же, новые версии SAS.Planet позволяют добавлять карты по шаблону, сведя к минимуму программирование. В самом простом случае zmp может состоять из всего одного файла [params.txt](zmp-params-txt.md). Просто добавьте обычный шаблон URL-адреса с плейсхолдерами. Например:

```
DefURLBase=https://opentopomaps.ru/{z}/{x}/{y}
```

Такой способ позволяет гораздо проще и быстрее добавлять карты, в URL которых присутствуют только стандартные параметры.

## Список допустимых плейсхолдеров для автозамены

| Плейсхолдер | Значение |
|-------------|----------|
| `{x}`       | Номер тайла по оси X (как в картах openstreetmap.org) |
| `{y}`       | Номер тайла по оси Y (как в картах openstreetmap.org) |
| `{z}`       | Уровень приближения/зума. Равен `GetZ-1`, т.е. начинается с нуля, как в картах openstreetmap.org |
| `{s}`       | Буква или цифра с номером зеркала сервера. Выбирается случайным образом из поля `ServerNames` в params.txt|
| `{a,b,c}` [^1] | Аналогично `{s}`, но список зеркал задаётся прямо в шаблоне |
| `{q}`       | Номер тайла в системе [QuadKey](https://learn.microsoft.com/en-us/bingmaps/articles/bing-maps-tile-system) (как в картах Bing). Как известно, Microsoft любит выпускать такие же продукты, как у других, но **другие**. |
| `{-y}`      | Инвертированный номер тайла по оси Y, для карт стандарта TMS. Т.е. "2 <sup>z</sup> - 1 - y", например nakarte.me |
| `{bbox}`    | Координаты границ тайла 256x256 пикселов (для WMS серверов) |
| `{timeStamp}` | Текущее время в формате UnixTime (для карт с пробками) |
| `{lang}`    | Язык |
| `{ver}`     | Версия |
| `{sas_path}` | Полный путь к тайлам для карт в формате SAS.Planet (Генштаб, Туристические). Заменяет `z{z+1}/{x/1024}/x{x}/{y/1024}/y{y}` |
| `{z+1}`     | Уровень зума карт в формате SAS.Planet |
| `{x/1024}`  | Номер первой подпапки карт в формате SAS.Planet |
| `{y/1024}`  | Номер второй подпапки карт в формате SAS.Planet |

С переменными `x`, `y`, `z` внутри шаблона можно выполнять простые математические операции: +, -, *, / (целочисленное деление). [^1]

[^1]: Начиная с версии 250204

## Инструкция

Для добавления новой карты нужно создать папку с названием, оканчивающемся на «.zmp». Например «Mapnik.zmp».

По желанию добавьте в эту папку файл с иконкой `24.bmp`, файл с текстовым описанием карты `info.txt`.

А вот файла `GetUrlSctipt.txt` в папке быть не должно! Именно когда его нет и запускается обработка URL по упрощённой схеме.

Теперь нужно создать файл `params.txt`. Заполните его в соответствии с [простым примером](zmp-example-base.md).

Только в поле `DefURLBase` вставляйте шаблон URL адреса. К примеру, вот так:

```
DefURLBase=https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
```

Ну, а если у сервера существует несколько зеркал, то их названия можно указать через запятую в поле `ServerNames`. Одно из них будет выбрано случайным образом и подставлено заместо плейсхолдера `{s}`:

```
ServerNames=a,b,c
```

## Примеры заполненных файлов params.txt

Карта с наиболее распространённой схемой нумерации тайлов slippy map:

```ini
[PARAMS]
GUID={A983EC9D-09D8-44D1-B263-B2A1DA1A20B1}
ParentSubMenu=OSM
name=OpenTopoMap.RU
NameInCache=OpenTopoMapRU
EPSG=3785
DefURLBase=https://tile-{s}.opentopomap.ru/{z}/{x}/{y}.png
ServerNames=a,b,c
Ext=.png
DetectContentType=1
ContentType=image/jpeg,image/png
```

Карта с инвертированной осью Y (стандарт TMS)

```ini
[PARAMS]
GUID={A983EC9D-09D8-44D1-B263-B2A1DA1A20B2}
ParentSubMenu_ru=Топокарты\ГГЦ
ParentSubMenu=Topomaps\GGC
name_ru=ГГЦ 2км
name=GGC 2km
NameInCache=ggc2km
EPSG=3785
DefURLBase=https://tiles.nakarte.me/ggc2000/{z}/{x}/{-y}
Ext=.png
DetectContentType=1
ContentType=image/jpeg,image/png
```

Карта с координатами QuadKey.

```ini
[PARAMS]
GUID={A983EC9D-09D8-44D1-B263-B2A1DA1A20B3}
ParentSubMenu_ru=Городские
ParentSubMenu=City
name=Bing
NameInCache=city_bing
EPSG=3785
DefURLBase=http://ak.dynamic.t{s}.tiles.virtualearth.net/comp/ch/{q}?mkt=en-us&it=A,G,L&shading=hill&og=8&n=z
ServerNames=1,2,3
Ext=.png
DetectContentType=1
ContentType=image/jpeg,image/png
```

Карта с системой хранения тайлов в формате SAS.Planet (короткий вариант)

```ini
[PARAMS]
GUID={A983EC9D-09D8-44D1-B263-B2A1DA1A20B4}
ParentSubMenu_ru=Топокарты\ГГЦ
ParentSubMenu=Topomaps\GGC
name_ru=ГГЦ 2км
name=GGC 2km
NameInCache=ggc2km
EPSG=3785
DefURLBase=http://91.237.82.95:8088/pub/ggc/2km.png/{sas_path}.jpg
Ext=.png
DetectContentType=1
ContentType=image/jpeg,image/png
```

Карта с системой хранения тайлов в формате SAS.Planet (длинный вариант)

```ini
[PARAMS]
GUID={A983EC9D-09D8-44D1-B263-B2A1DA1A20B4}
ParentSubMenu_ru=Топокарты\ГГЦ
ParentSubMenu=Topomaps\GGC
name_ru=ГГЦ 2км
name=GGC 2km
NameInCache=ggc2km
EPSG=3785
DefURLBase=http://91.237.82.95:8088/pub/ggc/2km.png/z{z+1}/{x/1024}/x{x}/{y/1024}/y{y}.jpg
Ext=.png
DetectContentType=1
ContentType=image/jpeg,image/png
```

Слой с эллипсоидной проекцией и указанием текущего времени              

```ini
[PARAMS]
GUID={A983EC9D-09D8-44D1-B263-B2A1DA1A20B5}
ParentSubMenu_ru=Городские
ParentSubMenu=City
name_ru=Яндекс Пробки
name=Yandex Traffic
NameInCache=yandex_traffic
asLayer=1
EPSG=3395
DefURLBase=https://core-jams-rdr.maps.yandex.net/1.1/tiles?trf&l=trf&lang=ru_RU&x={x}&y={y}&z={z}&scale=1&tm={timeStamp}
Ext=.png
DetectContentType=1
ContentType=image/jpeg,image/png
```

Слой с координатами типа bbox              

```ini
[PARAMS]
GUID={A983EC9D-09D8-44D1-B263-B2A1DA1A20B6}
ParentSubMenu_ru=Информационные
ParentSubMenu=Info
name_ru=РосРеестр
name=RosReestr
NameInCache=rosreestr
asLayer=1
EPSG=3785
DefURLBase=http://pkk5.rosreestr.ru/arcgis/rest/services/Cadastre/CadastreWMS/MapServer/export?bboxSR=102100&size=256%2C256&imageSR=102100&format=png32&transparent=true&dpi=96&f=image&bbox={bbox}
Ext=.png
DetectContentType=1
ContentType=image/jpeg,image/png
```
