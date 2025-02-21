# EPSG коды проекции

SAS.Планета поддерживает EPSG-коды для задания проекций в файле [params.txt](zmp-params-txt.md) (например, `EPSG=3785`), что заменяет необходимость указания параметров `projection`, `sradiusa`, `sradiusb`.

Чтобы для определённой карты задать проекцию **при выводе карты на экран** кодом EPSG, следует в файле [params.txt](zmp-params-txt.md) добавить раздел **[ViewInfo]** и в нём указать требуемое значение `EPSG`.

Код EPSG, указанный в разделе **[PARAMS]**, может отличаться от кода EPSG, указанного в разделе **[ViewInfo]**, что позволяет хранить тайлы в неизменном виде, а на экран выводить в желаемой проекции. 

Поддерживаются следующие коды:

## EPSG=3857[^1] (или 3785)

Проекция Меркатора на сфероид (`sradiusa` = `sradiusb`) [^2]. Используется в Google Maps, OpenStreetMap, Bing Maps и др. В старых терминах:

```ini
projection=1
sradiusa=6378137
sradiusb=6378137
```

## EPSG=3395

Проекция Меркатора на эллипсоид. Используется в Яндекс.Карты. В старых терминах:

```ini
projection=2
sradiusa=6378137
sradiusb=6356752
```

## EPSG=4326

Проекция типа широта-долгота. Используется в Google Earth. В старых терминах:

```ini
projection=3
sradiusa=6378137
sradiusb=6356752
```

---

См. также:

- [Системы координат в SAS Планете](coordinate-system.md)

[^1]: Начиная с версии 230721  
[^2]: [Wikipedia - Web Mercator projection](https://en.wikipedia.org/wiki/Web_Mercator_projection)
