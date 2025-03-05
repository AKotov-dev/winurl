program WinURL;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Process,
  Unit1,
  select_icons_unit { you can add units after this };

  {$R *.res}

  //Открываем адрес из файла.url
  procedure OpenURLFromFile;
  var
    ExProcess: TProcess;
  begin
    ExProcess := TProcess.Create(nil);
    try
      ExProcess.Executable := 'bash';
      ExProcess.Parameters.Add('-c');

      ExProcess.Parameters.Add('xdg-open $(grep "URL=" "' + ParamStr(1) +
        '" | cut -c 5- | col -b); exit 0');

      ExProcess.Execute;
    finally
      ExProcess.Free;
      Application.Free;
      Halt(1);
    end;
  end;

begin
  //Если параметр (1) не пуст, обрабатываем его (содержит имя файла.url с адресом узла)
  if ParamCount <> 0 then
    OpenURLFromFile;

  Application.Title:='WinURL v1.4';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
