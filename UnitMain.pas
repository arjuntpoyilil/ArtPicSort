unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,FileCtrl,IOUtils,System.Generics.Collections,
  BackgroundWorker, ShlObj;

type
  TFormMain = class(TForm)
    SourceLabel: TLabel;
    DestinationLabel: TLabel;
    SourceButton: TButton;
    DestinationButton: TButton;
    TransferButton: TButton;
    SourceEdit: TEdit;
    DestinationEdit: TEdit;
    ProgressBar: TProgressBar;
    LabelCopy: TLabel;
    RdBtnCopy: TRadioButton;
    RdBtnMove: TRadioButton;
    BackgroundWorker: TBackgroundWorker;
    ProgressBarSingle: TProgressBar;
    LabelFileName: TLabel;
    LabelPer: TLabel;
    procedure SourceButtonClick(Sender: TObject);
    procedure DestinationButtonClick(Sender: TObject);
    procedure BackgroundWorkerWork(Worker: TBackgroundWorker);
    procedure TransferButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure BackgroundWorkerWorkComplete(Worker: TBackgroundWorker;
      Cancelled: Boolean);
    procedure BackgroundWorkerWorkProgress(Worker: TBackgroundWorker;
      PercentDone: Integer);
  private
    TotalFiles,CurrentFile :Integer;
    procedure CopyFiles(const SourceDir, DestDir: string);
    function GetTotalFilesCount(const FolderPath: string): Integer;
    procedure UpdateProgressBar(Progress, MaxProgress: Integer);
    procedure UpdateControls(Working: Boolean);
    function GetFileSize(const FileName: string): Int64;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.SourceButtonClick(Sender: TObject);
var
  FolderDialog: TFileOpenDialog;
  FolderPath: string;
begin
  // Create an instance of the TFileOpenDialog component
  FolderDialog := TFileOpenDialog.Create(nil);
  try
    // Set the properties of the dialog
    FolderDialog.Title := 'Select a Folder';
    FolderDialog.Options := FolderDialog.Options + [fdoPickFolders];

    // Show the dialog and check if the user clicked the OK button
    if FolderDialog.Execute then
    begin
      // Get the selected folder path
      FolderPath := FolderDialog.FileName;
      SourceEdit.Text := FolderPath;
    end;
  finally
    // Free the dialog instance
    FolderDialog.Free;
  end;
end;

procedure TFormMain.TransferButtonClick(Sender: TObject);
begin
  CurrentFile :=0;
  if not DirectoryExists(SourceEdit.Text) then
  begin
    ShowMessage('Source folder does not exist.');
    Exit;
  end;

  if not DirectoryExists(DestinationEdit.Text) then
  begin
    ShowMessage('Destination folder does not exist.');
    Exit;
  end;
    // Display confirmation message
  if MessageDlg('This operation will create folders in the destination path with the format "yyyy\yyyy-MM-dd". Are you sure you want to continue?',mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  ProgressBarSingle.Position := 0;
  BackgroundWorker.Execute;
end;

procedure TFormMain.UpdateControls(Working: Boolean);
begin
  SourceButton.Enabled      := not Working;
  DestinationButton.Enabled := not Working;
  TransferButton.Enabled    := not Working;
  SourceEdit.Enabled        := not Working;
  DestinationEdit.Enabled   := not Working;
  RdBtnCopy.Enabled         := not Working;
  RdBtnMove.Enabled         := not Working;
end;

procedure TFormMain.UpdateProgressBar(Progress, MaxProgress: Integer);
begin
  ProgressBar.Min := 0;
  if MaxProgress =0 then
    MaxProgress :=1;
  ProgressBar.Max := MaxProgress;
  ProgressBar.Position := Progress;
  LabelPer.Caption     := FormatFloat('0.00',((Progress/MaxProgress)*100)) + '%';
  LabelPer.Update;
  ProgressBar.Update;
end;

procedure TFormMain.BackgroundWorkerWork(Worker: TBackgroundWorker);
begin
  if Worker.CancellationPending then
  begin
    // accept his/her request and exit
    Worker.AcceptCancellation;
    Exit;
  end;
  UpdateControls(True);
  TotalFiles := GetTotalFilesCount(SourceEdit.Text);
  UpdateProgressBar(0, TotalFiles);
  CopyFiles(SourceEdit.Text, DestinationEdit.Text) ;
end;

procedure TFormMain.BackgroundWorkerWorkComplete(Worker: TBackgroundWorker;
  Cancelled: Boolean);
begin
  UpdateControls(False);
  ShowMessage('Files transferred successfully.');
end;

procedure TFormMain.BackgroundWorkerWorkProgress(Worker: TBackgroundWorker;
  PercentDone: Integer);
begin
  ProgressBarSingle.Position := PercentDone;
end;

procedure TFormMain.CopyFiles(const SourceDir, DestDir: string);
const
  BufferSize = 64 * 1024;  // 64 KB buffer
var
  SearchRec: TSearchRec;
  SourcePath, DestPath,DestinationDir: string;
  Year, Month, Day: string;
  DateTime: TDateTime;
  FileExtensions: TArray<string>;
  ValueToCheck: string;
  Index: Integer;
  Found: Boolean;
  //SourceStream, DestStream: TFileStream;
  TotalBytes, BytesCopied: Int64;
  //Buffer: TBytes;
  //BytesRead, BytesToCopy: Integer;
  //Progress: Double;

  SourceStream, DestinationStream: TFileStream;
  Buffer: array [0..BufferSize - 1] of Byte;
  BytesRead, TotalBytesRead, FileSize: Int64;
  Progress: Double;
begin
  FileExtensions := [
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tif', '.tiff',   // Image formats
    '.cr2', '.nef', '.arw', '.dng', '.rw2', '.orf', '.raf',     // Camera raw formats
    '.avi', '.mp4', '.mov', '.wmv', '.mkv', '.flv', '.m4v'       // Video formats
  ];
  SourcePath := IncludeTrailingPathDelimiter(SourceDir);
  DestPath := IncludeTrailingPathDelimiter(DestDir);

  if FindFirst(SourcePath + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        ProgressBarSingle.Position := 1;
        LabelFileName.Caption := '';
        LabelFileName.Update;
        if (SearchRec.Attr and faDirectory) <> 0 then
        begin
          // Recursively copy files from subdirectories
          CopyFiles(SourcePath + SearchRec.Name, DestPath);
        end
        else
        begin
          // Copy only image and video files
          ValueToCheck := LowerCase(ExtractFileExt(SearchRec.Name));
          Found := False;

          for Index := Low(FileExtensions) to High(FileExtensions) do
          begin
            if FileExtensions[Index] = ValueToCheck then
            begin
              Found := True;
              Break;
            end;
          end;

          if Found  then
          begin
              DateTime := FileDateToDateTime(SearchRec.Time);
              Year := FormatDateTime('yyyy', DateTime);
              Month := FormatDateTime('MM', DateTime);
              Day := FormatDateTime('dd', DateTime);

              // Create destination folders based on the file's creation date
              DestinationDir := DestPath + year + '\' + Year + '-' + Month + '-' + Day;
              ForceDirectories(DestinationDir);
              LabelFileName.Caption := SearchRec.Name;
              LabelFileName.Update;

              // Get the size of the source file
              TotalBytes := GetFileSize(SourcePath + SearchRec.Name);
              if TotalBytes < 0 then
                Exit;  // Error occurred, cannot get file size

              SourceStream := TFileStream.Create(SourcePath + SearchRec.Name, fmOpenRead or fmShareDenyWrite);
              try
                FileSize := SourceStream.Size;

                DestinationStream := TFileStream.Create(IncludeTrailingPathDelimiter(DestinationDir) + SearchRec.Name, fmCreate);
                try
                  BytesRead := SourceStream.Read(Buffer, BufferSize);
                  TotalBytesRead := 0;

                  while BytesRead > 0 do
                  begin
                    DestinationStream.WriteBuffer(Buffer, BytesRead);

                    TotalBytesRead := TotalBytesRead + BytesRead;
                    Progress := TotalBytesRead / FileSize * 100;

                    // Update progress here (e.g., update progress bar)
                    ProgressBarSingle.Position := Round(Progress);
                    ProgressBarSingle.Update;

                    BytesRead := SourceStream.Read(Buffer, BufferSize);
                  end;
                finally
                  DestinationStream.Free;
                  // Restore the original file modified date
                  TFile.SetLastWriteTime(IncludeTrailingPathDelimiter(DestinationDir) + SearchRec.Name, TFile.GetLastWriteTime(SourcePath + SearchRec.Name));
                end;
              finally
                SourceStream.Free;
              end;
              LabelFileName.Caption := '';
              LabelFileName.Update;
              if RdBtnMove.Checked then
              begin
                // Delete the source file
                TFile.Delete(SourcePath + SearchRec.Name);
              end;
//              if RdBtnCopy.Checked then
//                TFile.Copy(SourcePath + SearchRec.Name, IncludeTrailingPathDelimiter(DestinationDir) + SearchRec.Name)
//              else
//                TFile.Move(SourcePath + SearchRec.Name, IncludeTrailingPathDelimiter(DestinationDir) + SearchRec.Name);
              Inc(CurrentFile);
              UpdateProgressBar(CurrentFile, TotalFiles);
          end;
        end;
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

procedure TFormMain.DestinationButtonClick(Sender: TObject);
var
  FolderDialog: TFileOpenDialog;
  FolderPath: string;
begin
  // Create an instance of the TFileOpenDialog component
  FolderDialog := TFileOpenDialog.Create(nil);
  try
    // Set the properties of the dialog
    FolderDialog.Title := 'Select a Folder';
    FolderDialog.Options := FolderDialog.Options + [fdoPickFolders];

    // Show the dialog and check if the user clicked the OK button
    if FolderDialog.Execute then
    begin
      // Get the selected folder path
      FolderPath := FolderDialog.FileName;
      DestinationEdit.Text := FolderPath;
    end;
  finally
    // Free the dialog instance
    FolderDialog.Free;
  end;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // if background worker is still running
  if BackgroundWorker.IsWorking then
  begin
    // request for cancellation
    BackgroundWorker.Cancel;
    // and wait for its termination
    BackgroundWorker.WaitFor;
  end;
  Action := caFree;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  UpdateControls(False);
end;

function TFormMain.GetFileSize(const FileName: string): Int64;
var
  FileInfo: TWin32FileAttributeData;
begin
  if GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @FileInfo) then
  begin
    Int64Rec(Result).Lo := FileInfo.nFileSizeLow;
    Int64Rec(Result).Hi := FileInfo.nFileSizeHigh;
  end
  else
    Result := -1;
end;

function TFormMain.GetTotalFilesCount(const FolderPath: string): Integer;
var
  SearchRec: TSearchRec;
begin
  Result := 0;

  // Find the first file in the folder
  if FindFirst(IncludeTrailingPathDelimiter(FolderPath) + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        // Check if the found item is a file
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and
           (SearchRec.Attr and faDirectory = 0) then
          Inc(Result);

        // Check if the found item is a subfolder
        if (SearchRec.Attr and faDirectory <> 0) and
           (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
          Inc(Result, GetTotalFilesCount(IncludeTrailingPathDelimiter(FolderPath) + SearchRec.Name));
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

end.
