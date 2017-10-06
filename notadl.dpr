program notadl;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, System.Classes, IdHTTP;

{$SETPEFLAGS IMAGE_FILE_RELOCS_STRIPPED}

var
  MemoryStream1: TMemoryStream;
  IdHTTP1: TIdHTTP;
  StringList1: TStringList;
  i, x, y: Integer;
  s, ChapterId, ChapterName, OutDir: String;
begin
  try
    Writeln('Notabenoid Downloader v1.0 by RikuKH3');
    Writeln('-------------------------------------');
    if ParamCount<3 then begin Writeln('Usage: '+ExtractFileName(ParamStr(0))+' <login> <password> <book>'); Readln; exit end;

    StringList1:=TStringList.Create; MemoryStream1:=TMemoryStream.Create;
    try
      StringList1.Append('login[login]='+ParamStr(1));
      StringList1.Append('login[pass]='+ParamStr(2));
      IdHTTP1:=TIdHTTP.Create(nil);
      try
        IdHTTP1.AllowCookies := True;
        IdHTTP1.HandleRedirects := True;
        IdHTTP1.Post('http://notabenoid.org', StringList1);
        IdHTTP1.Get('http://notabenoid.org/book/'+ParamStr(3), MemoryStream1);
        MemoryStream1.Position := 0;
        StringList1.LoadFromStream(MemoryStream1, TEncoding.UTF8);
        MemoryStream1.Clear;

        x := 0;
        for i:=0 to StringList1.Count-1 do begin
          x := Pos('<tr id='#39'c_', StringList1[i]);
          if x>0 then begin
            s:=StringList1[i];
            OutDir := ExtractFilePath(ParamStr(0))+'book_'+ParamStr(3);
            if not (DirectoryExists(OutDir)) then CreateDir(OutDir);
            break
          end
        end;

        while x>0 do begin
          x := Pos('<a href=', s);
          s := Copy(s, x+9);
          i := Pos(#39, s);
          ChapterId := Copy(s, 1, i-1);
          s := Copy(s, i+2);
          ChapterName := Copy(s, 1, Pos('</a>',s)-1);
          x := Pos('<tr id='#39'c_', s);
          s := Copy(s, x);
          IdHTTP1.Get('http://notabenoid.org'+ChapterId+'/download?format=t&enc=UTF-8', MemoryStream1);
          MemoryStream1.Position := 0;
          StringList1.LoadFromStream(MemoryStream1);
          MemoryStream1.Clear;

          y := -1;
          if StringList1.Count>0 then for i:=StringList1.Count-1 downto 0 do if StringList1[i]='Переведено на Нотабеноиде' then begin y:=i; break end;
          if y>-1 then begin
            if y-3>-1 then begin
              if StringList1[y-3]='Внимание! Этот перевод, возможно, ещё не готов.' then for i:=0 to StringList1.Count-y+3 do StringList1.Delete(StringList1.Count-1) else for i:=0 to StringList1.Count-y do StringList1.Delete(StringList1.Count-1);
            end else for i:=0 to StringList1.Count-y-1 do StringList1.Delete(StringList1.Count-1);
          end;

          Writeln(OutDir+'\'+ChapterName+'.txt');
          StringList1.SaveToFile(OutDir+'\'+ChapterName+'.txt', TEncoding.UTF8);
        end;
      finally IdHTTP1.Free end;
    finally StringList1.Free; MemoryStream1.Free end;
  except on E: Exception do begin Writeln(E.Message); Readln end end;
end.
