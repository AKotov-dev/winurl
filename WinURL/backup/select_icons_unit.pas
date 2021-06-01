unit select_icons_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, Process;

type

  { TSelectIconsForm }

  TSelectIconsForm = class(TForm)
    Image1: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Image1Click(Sender: TObject);
  private

  public

  end;

var
  SelectIconsForm: TSelectIconsForm;

implementation

{$R *.lfm}

{ TSelectIconsForm }

procedure TSelectIconsForm.Image1Click(Sender: TObject);
var
  ExProcess: TProcess;
begin
  // Screen.Cursor := crHourGlass;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := 'bash';

    ExProcess.Parameters.Add('-c');

    ExProcess.Parameters.Add('cp -rf "' + ExtractFilePath(Application.ExeName) +
      'ico/' + IntToStr((Sender as TImage).tag) + '/share"' +
      ' ~/.local; xdg-icon-resource forceupdate; gtk-update-icon-cache');

    //ExProcess.Options := ExProcess.Options + [poWaitOnExit];
    ExProcess.Execute;
  finally

    ExProcess.Free;
    // Screen.Cursor := crDefault;
    SelectIconsForm.Close;
  end;
end;

procedure TSelectIconsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  SelectIconsForm := Nil;
end;

end.



