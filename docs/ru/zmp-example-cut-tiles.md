# Пример порезки на тайлы

- **CutCountX=0** - число кусков по X, необязательный параметр
- **CutCountY=0** - соответственно по Y
- **CutSizeX=0** - размер куска по X, если не задано — берётся 256 из параметров
- **CutSizeY=0** - соответственно по Y
- **CutTileX=0** - положение запрошенного тайла в общей картинке по X
- **CutTileY=0** - соответственно по Y
- **CutToSkip=(0,0),(0,-1)** - перечень тайлов, которые нужно пропускать (относительно *CutTileX*, *CutTileY*)

Запрашиваем с сервера большую картинку 1024x1024 - это шестнадцать тайлов (4x4).

![](assets/tiles_grid.png)

Запрашиваемый тайл - левый верхний угол. Устанавливаем параметры в `params.txt`:

```ini
[PARAMS]
CutCountX=4   // Тайлов по горизонтали
CutCountY=4   // Tайлов по горизонтали
CutSizeX=256  // Размер в пикселях
CutSizeY=256
CutTileX=0    // Координата Х тайла от которого ведётся отсчёт
CutTileY=0    // Координата Y тайла от которого ведётся отсчёт
```

Так как нам не нужно пропускать тайлы с копирайтами, то параметр **CutToSkip** оставляем пустым.

Для этого примера `GetUrlScript.txt` выглядит так:

```pascal
var
 tl, br: TPoint;
 topLeftM, bottomRightM: TDoublePoint;
begin
  tl.x := GetX;
  tl.y := GetY;

  br.x := GetX+4;
  br.y := GetY+4;

  topLeftM     := Converter.Pos2LonLat(tl, GetZ-1);
  bottomRightM := Converter.Pos2LonLat(br, GetZ-1);
  
  ResultURL := GetURLBase + '&BBOX=' + 
    RoundEx(topLeftM.X, 10) + ',' + 
    RoundEx(bottomRightM.Y, 10) + ',' + 
    RoundEx(bottomRightM.X, 10) + ',' +
    RoundEx(topLeftM.Y, 10); 
end.
```

