unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, XMLPropStorage, StdCtrls, LCLTranslator, DefaultTranslator,
  LCLType, PopupNotifier, Process;
//Types

type

  { TMainForm }

  TMainForm = class(TForm)
    PopupNotifier1: TPopupNotifier;
    SelectBtn: TBitBtn;
    CreateBtn: TBitBtn;
    PathEdit: TEdit;
    Label4: TLabel;
    NameEdit: TEdit;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SelPathBtn: TSpeedButton;
    URLEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    XMLPropStorage1: TXMLPropStorage;
    procedure PopupNotifier1Close(Sender: TObject; var CloseAction: TCloseAction);
    procedure SelectBtnClick(Sender: TObject);
    procedure CreateBtnClick(Sender: TObject);
    procedure NameEditClick(Sender: TObject);
    procedure SelPathBtnClick(Sender: TObject);
    procedure URLEditClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure DetoxName; //Валидация/правка имени ярлыка *.url
    procedure Timer1Timer(Sender: TObject);
    procedure MateCMenuCreate;

  private

  public

  end;

resourcestring
  SPermissionDenied = 'Access error! Change the target directory!';
  SFileExists = 'The file already exists! Overwrite it?';
  STitle = 'Design example...';
  SNameInput = 'Name: Yandex search engine';
  SMATE_CMenu = 'Create Internet ShortCut';

var
  MainForm: TMainForm;
  a: integer; //Timer counter

implementation

uses select_icons_unit;

{$R *.lfm}

{ TMainForm }


//Создаём опцию "Создать интернет-ярлык" в контекстном меню MATE (ПКМ)
procedure TMainForm.MateCMenuCreate;
var
  ExProcess: TProcess;
begin
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := 'bash';  //sh или xterm
    ExProcess.Parameters.Add('-c');

    ExProcess.Parameters.Add('mkdir -p ~/.config/caja/scripts; echo -e ' +
      '''' + '#!/bin/bash\n\n/usr/share/WinURL/WinURL || rm "$0"' +
      '''' + ' > ~/.config/caja/scripts/"' + SMATE_CMenu + '"; chmod +x ' +
      GetEnvironmentVariable('HOME') + '/.config/caja/scripts/"' + SMATE_CMenu + '"');

    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

//Валидация имён создаваемых ярлыков
procedure TMainForm.DetoxName;
const
  BadSym = '={}$\/:*?"<>|@^.#%&~'''; //Заменять эти символы
  //Заменять эти фразы
  BadWord: array[0..5] of string = ('CON', 'PRN', 'AUX', 'NUL', 'COM', 'LPT');
var
  i: integer;
  S: string;
begin
  //Заменяем неразрешенные символы
  S := Trim(NameEdit.Text);

  for i := 1 to Length(S) do
    if Pos(S[i], BadSym) > 0 then
      S[i] := '_';

  //Заменяем неразрешенные фразы
  for i := 0 to 5 do
    S := StringReplace(S, BadWord[i], '---', [rfReplaceAll]);

  //Урезаем длину имени до 200 символов
  if Length(S) > 255 then
    S := Copy(S, 1, 255);

  NameEdit.Text := S;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  if a = 0 then
  begin
    Timer1.Enabled := False;
    PopupNotifier1.Hide;
  end;

  Dec(a);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Создаём рабочую директорию, если нет
  if not DirectoryExists(GetEnvironmentVariable('HOME') + '/.WinURL') then
    MkDir(GetEnvironmentVariable('HOME') + '/.WinURL');

  //Конфиг
  XMLPropStorage1.FileName := GetEnvironmentVariable('HOME') +
    '/.WinURL/settings.xml';

  //Проверяем наличие скрипта CMenu WinURL для MATE (имя из переведённого ресурса)
  if not FileExists(GetEnvironmentVariable('HOME') + '/.config/caja/scripts/' +
    SMATE_CMenu) then
    MateCMenuCreate;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    CreateBtn.Click;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  MainForm.Caption := Application.Title;

  //Первый запуск... Ищем Рабочий стол...
  if Trim(PathEdit.Text) = '' then
    if DirectoryExists(GetEnvironmentVariable('HOME') + '/Desktop') then
      SelectDirectoryDialog1.FileName := GetEnvironmentVariable('HOME') + '/Desktop'
    else
    if DirectoryExists(GetEnvironmentVariable('HOME') + '/Рабочий стол') then
      SelectDirectoryDialog1.FileName :=
        GetEnvironmentVariable('HOME') + '/Рабочий стол'
    else
      SelectDirectoryDialog1.FileName := GetEnvironmentVariable('HOME');

  PathEdit.Text := SelectDirectoryDialog1.FileName;
end;

procedure TMainForm.CreateBtnClick(Sender: TObject);
var
  S: TStringList;
begin
  a := 3; //Задержка показа предупреждения валидации

  PopUpNotifier1.Title := STitle;
  PopUpNotifier1.Text := 'URL: https://yandex.ru' + #13#10 + SNameInput;

  //Валидация вводимых URL: и Имя:
  if (Trim(URLEdit.Text) <> '') and ((Pos('http://', URLEdit.Text) <> 0) or
    (Pos('https://', URLEdit.Text) <> 0) or (Pos('ftp://', URLEdit.Text) <> 0)) and
    (Trim(NameEdit.Text) <> '') then

  begin
    DetoxName; //Валидация/правка имени ярлыка
    try
      S := TStringList.Create;
      S.Add('[InternetShortcut]');
      S.Add('URL=' + Trim(URLEdit.Text));

      if FileExists(PathEdit.Text + '/' + NameEdit.Text + '.url') then
        if MessageDlg(SFileExists, mtWarning, [mbYes, mbNo], 0) <> mrYes then
        begin //Если отказ от перезаписи существующего файла - выход
          S.Free;
          Exit;
        end;

      S.SaveToFile(PathEdit.Text + '/' + NameEdit.Text + '.url');
      S.Free;
    except  //finally закрывает приложение
      MessageDlg(SPermissionDenied, mtError, [mbOK], 0);
      S.Free;
    end;
  end
  else
  begin
    PopupNotifier1.ShowAtPos(MainForm.Left, MainForm.Top);
    Timer1.Enabled := True;
    Exit;
  end;
end;

procedure TMainForm.SelectBtnClick(Sender: TObject);
begin
  if SelectIconsForm = nil then
    SelectIconsForm := TSelectIconsForm.Create(Application);

  SelectIconsForm.Left := MainForm.Left;
  SelectIconsForm.Top := MainForm.Top;

  SelectIconsForm.Show;
end;

procedure TMainForm.PopupNotifier1Close(Sender: TObject; var CloseAction: TCloseAction);
begin
  Timer1.Enabled := False;
end;

procedure TMainForm.NameEditClick(Sender: TObject);
begin
  NameEdit.SelectAll;
end;

procedure TMainForm.SelPathBtnClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
  begin
    PathEdit.Text := SelectDirectoryDialog1.FileName;
    URLEdit.SetFocus;
  end;
end;

procedure TMainForm.URLEditClick(Sender: TObject);
begin
  URLEdit.SelectAll;
end;

end.
