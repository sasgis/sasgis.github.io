# Описание скриптов Pascal

Файл **GetUrlScript.txt** содержит скрипт, написанный на языке Pascal, и предназначен для формирования параметров запроса тайла, к которым относятся:

- Полный адрес ссылки на тайлы данной карты.
- HTTP-заголовки, передаваемые серверу при запросе тайла карты.

## Переменные, доступные в скриптах

- **GetURLBase** (`AnsiString`) — неизменная часть адреса ссылки на тайлы карты, соответствует параметру **DefURLBase** в `params.txt`.
- **RequestHead** (`AnsiString`) — заголовки, которые будут переданы серверу при запросе (проинициализирована значением **RequestHead** из `params.txt`).
- **Version** (`AnsiString`) — версия тайлов, соответствует параметру **Version** в `params.txt`.
- **Lang** (`AnsiString`) — язык, соответствует языку интерфейса программы. Принимает значения: `'en'`, `'ru'`, `'uk'` и т.д.
- **GetX, GetY, GetZ** (`Integer`) — соответственно номер тайла по горизонтали (слева), по вертикали (сверху), масштаб (от 1 до 24).
- **GetLLon, GetRLon, GetTLat, GetBLat** (`Double`) — соответственно долгота левой границы тайла, правой границы, широта верхней границы, нижней границы.
- **GetLMetr, GetRMetr, GetTMetr, GetBMetr** (`Double`) — то же в метрах.
- **ResponseHead** (`AnsiString`) — заголовки ответа сервера от предыдущего запроса.
- **ScriptBuffer** (`AnsiString`) — буфер для хранения любой информации, сохраняемой между вызовами скрипта (для конкретного потока).
- **ResultURL** (`AnsiString`) — сюда нужно сформировать ссылку на тайл.
- **PostData** (`AnsiString`) — если в скрипте в строковую переменную `PostData` поместить какие-то данные, то будет выполнен POST запрос вместо GET запроса.

## Интерфейсные переменные, доступные в скриптах

- **Downloader** (`ISimpleHttpDownloader`) — выполнение HTTP запросов внутри скрипта. Доступно только при включённой опции **IsUseDownloaderInScript** в `params.txt`.
- **DefProjConverter** (`IProjConverter`) — конвертер координат в проекции, определённой в `params.txt` (параметр **Proj4Args**). Доступна только при наличии **proj.dll**.
- **ProjFactory** (`IProjConverterFactory`) — фабрика, для создания конвертеров координат различных проекций. Доступна только при наличии **proj.dll**.
- **Converter** (`ICoordConverter`) — набор функций для работы с координатами в текущей проекции.
- **TileCache** (`IPascalScriptTileCache`) — доступ к кэшу тайлов (чтение/запись/удаление).
- **Logger** (`IPascalScriptLogger`) — запись логов на диск, для последующего анализа.
- **Global** (`IPascalScriptGlobal`) — объект для глобальной блокировки и доступа к переменным между всеми потоками, одновременно использующими скрипт. К примеру, если в params.txt указано **MaxConnectToServerCount=4**, то загрузка тайлов может производиться четырьмя потоками одновременно. При этом, у каждого потока будет свой экземпляр переменной **ScriptBuffer**, и если по каким-то причинам вам нужно обмениваться данными между всеми потоками, то это можно сделать только через переменную **Global**.

!!! note
    Интерфейсные переменные могут быть не инициализированы (т.е. равны `nil`). Перед использованием их необходимо проверять при помощи функции [**Assigned**](http://delphibasics.ru/Assigned.php).

## Описание интерфейсов и примеры их использования

### Выполнение HTTP запросов из скрипта

В zmp должно быть включена возможность выполнять HTTP запросы **IsUseDownloaderInScript=1**.

В скрипте можно пользоваться переменной **Downloader**. Если она не пустая, то можно выполнять `DoHttpRequest`.

```delphi
ISimpleHttpDownloader = interface    
  function DoHttpRequest(
    const ARequestUrl, ARequestHeader, APostData: AnsiString;
    out AResponseHeader, AResponseData: AnsiString
  ): Cardinal;
end;
```

Пример:

```delphi
var
  VRequestUrl, VRequestHeader, VPostData: string;
  VResponseCode: Cardinal;
  VResponseHeader, VResponseData: string; 
begin 
  if Assigned(Downloader) then begin
    VRequestUrl := 'https://google.com/';
    VRequestHeader := '';
    VPostData := '';
    VResponseHeader := '';
    VResponseData := '';
    
    VResponseCode := Downloader.DoHttpRequest(VRequestUrl, VRequestHeader,
      VPostData, VResponseHeader, VResponseData);
  
    if VResponseCode = 200 then begin
      ScriptBuffer := VResponseData;
    end else begin
      ScriptBuffer := VResponseHeader;
    end; 
  end;
end.
```

### Работа с хитрыми системами координат

Если в папке с программой присутствует `proj.dll`, то в скриптах будут доступны такие переменные:

- **DefProjConverter** с объектом типа:

```delphi
IProjConverter = interface
  function LonLat2XY(const AProjLP: TDoublePoint): TDoublePoint;
  function XY2LonLat(const AProjXY: TDoublePoint): TDoublePoint;
end;
```

Будет инициализирована, если параметр `Proj4Args` в zmp-файле равен правильной строке инициализации библиотеки proj, иначе там будет `nil`.

- **ProjFactory** с объектом типа:

```delphi
IProjConverterFactory = interface
  function GetByEPSG(const AEPSG: Integer): IProjConverter;
  function GetByInitString(const AArgs: String): IProjConverter;
end;
```

Позволяет создавать конвертеры по требованию, например с учетом зон и т. д.

Пример:

```delphi
var
  VEPSG: Integer;
  Proj4Conv: IProjConverter;
begin
  // use EPSG:28483 aka EPSG:2513
  // check bounds (EPSG:28483 between 132E and 138E) and correct EPSG (inc or dec)
  VEPSG := 28483;
  if GetLLon < 132 then begin
    VEPSG := VEPSG - 1;
  end else 
  if GetLLon > 138 then begin
    VEPSG := VEPSG + 1;
  end;
  
  // get proj4 converter
  Proj4Conv := ProjFactory.GetByEPSG(VEPSG - (28483 - 2513));
  if Assigned(Proj4Conv) then begin
    // Тут генерируем Url
  end else begin
    // not available
    ResultURL := '';
  end;
end.
```
### Работа с координатами

```delphi
ICoordConverter = interface
  // Преобразует позицию тайла на заданном зуме в географические координаты его верхнего левого угла
  function Pos2LonLat(const XY: TPoint; AZoom: byte): TDoublePoint; stdcall;
  // Преобразует географические координаты в позицию тайла на заданном зуме накрывающего данные координаты
  function LonLat2Pos(const Ll: TDoublePoint; AZoom: byte): TPoint; stdcall;

  // метрические координаты
  function LonLat2Metr(const Ll: TDoublePoint): TDoublePoint; stdcall;
  function Metr2LonLat(const Mm: TDoublePoint): TDoublePoint; stdcall;

  // Возвращает количество тайлов в заданном зуме
  function TilesAtZoom(const AZoom: byte): Longint; stdcall;
  // Возвращает общее количество пикселей на заданном зуме
  function PixelsAtZoom(const AZoom: byte): Longint; stdcall;

  // Преобразует позицию тайла заданного зума в координаты пиксела его левого верхнего угла
  function TilePos2PixelPos(const XY: TPoint; const AZoom: byte): TPoint; stdcall;
  // Преобразует позицию тайла заданного зума в номера пикселов его углов на заданном зуме
  function TilePos2PixelRect(const XY: TPoint; const AZoom: byte): TRect; stdcall;
end;
```

Пример:

```delphi
var
  VTilesCount: Integer;
begin
  if Assigned(Converter) then begin
    VTilesCount := Converter.TilesAtZoom(GetZ);
    // производим расчёты и генерируем url
  end else begin
    ResultURL := '';
  end;
end.
```
### Логгер

```delphi
IPascalScriptLogger = interface
  procedure Write(const AStr: AnsiString);
  procedure WriteFmt(const AFormat: string; const AArgs: array of const);
end;
```

### Доступ к кэшу

```delphi
TPascalScriptTileInfo = packed record
  IsExists    : Boolean;
  IsExistsTne : Boolean;
  LoadDate    : Int64; // unix timestamp
  Size        : Cardinal;
  Version     : string;
  ContentType : AnsiString;
  Data        : AnsiString;
end;

IPascalScriptTileCache = interface
  function Read(
    const X: Integer;
    const Y: Integer;
    const AZoom: Byte;
    const AVersion: string;
    const AWithData: Boolean
  ): TPascalScriptTileInfo;

  function Write(
    const X: Integer;
    const Y: Integer;
    const AZoom: Byte;
    const AVersion: string;
    const AContentType: AnsiString;
    const AData: AnsiString;
    const AIsOverwrite: Boolean
  ): Boolean;

  function WriteTne(
    const X: Integer;
    const Y: Integer;
    const AZoom: Byte;
    const AVersion: string
  ): Boolean;

  function Delete(
    const X: Integer;
    const Y: Integer;
    const AZoom: Byte;
    const AVersion: string
  ): Boolean;
end;
```

### Глобальные переменные

```delphi
IPascalScriptGlobal = interface  
  procedure Lock;
  procedure Unlock;

  procedure LockRead;
  procedure UnlockRead;

  procedure SetVar(const AVarID: Integer; const AValue: Variant);
  procedure SetVarTS(const AVarID: Integer; const AValue: Variant);

  function GetVar(const AVarID: Integer): Variant;
  function GetVarTS(const AVarID: Integer): Variant;

  function Exists(const AVarID: Integer): Boolean;
  function ExistsTS(const AVarID: Integer): Boolean;
end;
```
Методы помеченные как `TS` (Thread-Safe) можно использовать без блокировки.

Пример:

```delphi
function _GetVersion(out AVersion: AnsiString): Boolean;
begin
  if ScriptBuffer = '' then begin
    Global.Lock;
    try
      if Global.Exists(0) then begin
        ScriptBuffer := Global.GetVar(0);
        if ScriptBuffer = '' then begin // this should never happen
          ScriptBuffer := cErrorFlag;
        end;
      end else begin
        if _RequestVersion(ScriptBuffer) then begin
          Global.SetVar(0, ScriptBuffer);
        end;
      end;
    finally
      Global.Unlock;
    end;
  end;

  if (ScriptBuffer <> '') and (ScriptBuffer <> cErrorFlag) then begin
    AVersion := ScriptBuffer;
  end else begin
    AVersion := Version; // fallback to the Version from Params.txt
  end;
  
  Result := AVersion <> '';
end;
```
## Функции, доступные в скриптах

```delphi
function Assigned(const I: LongInt): Boolean;
procedure _T(const Name: tbtString; const V: Variant);
function _T(const Name: tbtString): Variant;
function IntToStr(const I: Int64): string;
function StrToInt(const S: string): LongInt;
function StrToIntDef(const S: string; const def: LongInt): LongInt;
function Copy(const S: AnyString; const iFrom: LongInt; const iCount: LongInt): AnyString;
function Pos(const SubStr: AnyString; const S: AnyString): LongInt;
procedure Delete(var S: AnyString; const iFrom: LongInt; const iCount: LongInt);
procedure Insert(const S: AnyString; var s2: AnyString; const iPos: LongInt);
function GetArrayLength(const Arr): LongInt;
procedure SetArrayLength(var arr; const count: LongInt);
function StrGet(var S: string; const I: LongInt): Char;
function StrGet2(const S: string; const I: LongInt): Char;
procedure StrSet(const C: Char; const I: LongInt; var S: string);
function WStrGet(var S: AnyString; const I: LongInt): WideChar;
procedure WStrSet(const C: AnyString; const I: LongInt; var S: AnyString);
function VarArrayGet(var S: Variant; const I: LongInt): Variant;
procedure VarArraySet(const C: Variant; const I: LongInt; var S: Variant);
function AnsiUpperCase(const S: string): string;
function AnsiLowerCase(const S: string): string;
function UpperCase(const S: AnyString): AnyString;
function LowerCase(const S: AnyString): AnyString;
function Trim(const S: AnyString): AnyString;
function Length(const S): LongInt;
procedure SetLength(var s; const NewLength: LongInt);
function Low(const X): Int64;
function High(const X): Int64;
procedure Dec(var x);
procedure Inc(var x);
procedure Include(var s; const m);
procedure Exclude(var s; const m);
function Sin(const E: Extended): Extended;
function Cos(const E: Extended): Extended;
function Sqrt(const E: Extended): Extended;
function Round(const E: Extended): LongInt;
function Trunc(const E: Extended): LongInt;
function Int(const E: Extended): Extended;
function Pi: Extended;
function Abs(const E: Extended): Extended;
function StrToFloat(const S: string): Extended;
function FloatToStr(const E: Extended): string;
function PadL(const S: AnyString; const I: LongInt): AnyString;
function PadR(const S: AnyString; const I: LongInt): AnyString;
function PadZ(const S: AnyString; const I: LongInt): AnyString;
function Replicate(const C: Char; const I: LongInt): string;
function StringOfChar(const C: Char; const I: LongInt): string;
function Unassigned: Variant;
function VarIsEmpty(const V: Variant): Boolean;
function VarIsClear(const V: Variant): Boolean;
function Null: Variant;
function VarIsNull(const V: Variant): Boolean;
function VarType(const V: Variant): Word;
procedure RaiseLastException;
procedure RaiseException(const Ex: TIFException; const Param: string);
function ExceptionType: TIFException;
function ExceptionParam: string;
function ExceptionProc: LongWord;
function ExceptionPos: LongWord;
function ExceptionToString(const er: TIFException; const Param: string): string;
function StrToInt64(const S: string): Int64;
function Int64ToStr(const I: Int64): string;
function StrToInt64Def(const S: string; const def: Int64): Int64;
function SizeOf(const Data): LongInt;
function IdispatchInvoke(const Self: IDispatch; const PropertySet: Boolean; const Name: AnsiString; const Par: array of Variant): Variant;
function Random(const X: LongInt): LongInt;
function RandomRange(const AFrom: LongInt; const ATo: LongInt): LongInt;
function Power(const Base: Extended; const Exponent: Extended): Extended;
function IntPower(const Base: Extended; const Exponent: LongInt): Extended;
function Ceil(const X: Extended): LongInt;
function Floor(const X: Extended): LongInt;
function Log2(const X: Extended): Extended;
function Ln(const X: Extended): Extended;
function Max(const A: LongInt; const B: LongInt): LongInt;
function MaxExt(const A: Extended; const B: Extended): Extended;
function Min(const A: LongInt; const B: LongInt): LongInt;
function MinExt(const A: Extended; const B: Extended): Extended;
function RegExprGetMatchSubStr(const Str: AnsiString; const MatchExpr: AnsiString; const AMatchID: LongInt): AnsiString;
function RegExprReplaceMatchSubStr(const Str: AnsiString; const MatchExpr: AnsiString; const Replace: AnsiString): AnsiString;
function Base64Encode(const Data: AnsiString): AnsiString;
function Base64UrlEncode(const Data: AnsiString): AnsiString;
function Base64Decode(const Data: AnsiString): AnsiString;
function IntToHex(const Value: LongInt; const Digits: LongInt): string;
function FileExists(const FileName: string): Boolean;
function Format(const Format: string; const Args: array of const): string;
function FormatEx(const Format: string; const Args: array of const; const ADecimalSeparator: Char): string;
function PosEx(const SubStr: string; const S: string; const Offset: LongInt): LongInt;
function StringReplace(const S: AnsiString; const OldPattern: AnsiString; const NewPattern: AnsiString; const Flags: TReplaceFlags): AnsiString;
function MD5String(const AStr: AnsiString): string;
function RoundEx(const chislo: Double; const Precision: LongInt): string;
function GetAfter(const SubStr: AnsiString; const Str: AnsiString): AnsiString;
function GetBefore(const SubStr: AnsiString; const Str: AnsiString): AnsiString;
function GetBetween(const Str: AnsiString; const After: AnsiString; const Before: AnsiString): AnsiString;
function SetHeaderValue(const AHeaders: AnsiString; const AName: AnsiString; const AValue: AnsiString): AnsiString;
function GetHeaderValue(const AHeaders: AnsiString; const AName: AnsiString): AnsiString;
function DeleteHeaderEntry(const AHeaders: AnsiString; const AName: AnsiString): AnsiString;
function SubStrPos(const Str: AnsiString; const SubStr: AnsiString; const FromPos: LongInt): LongInt;
function GetNumberAfter(const ASubStr: string; const AText: string): string;
function GetDiv3Path(const ANumber: string): string;
function GetUnixTime: Int64;
function SaveToLocalFile(const AFullLocalFilename: string; const AData: AnsiString): LongInt;
procedure WriteLn(const s: string);
function TemplateToUrl(const ATmpl: string): string;
```

## Использование автозамены плейсхолдеров

Если файла **GetUrlScript.txt** нет или он пуст (в том числе не содержит ни пробелов, ни переводов строк), то будет выполнен скрипт, который автоматически заменяет плейсхолдеры, найденные в **GetURLBase**. Именно в этом формате он применяется при [упрощенном добавлении карт](zmp-url-templates.md). Однако, если вам потребуется, то вы можете использовать эту функцию в собственных скриптах:

```delphi
begin
  ResultUrl := TemplateToUrl(GetURLBase);
end.
```