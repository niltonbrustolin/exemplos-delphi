unit Base.Form.Dados;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Base.Form, Data.DB, Base.Data.Cadastro,
  System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.DBActns;

type
  TfrmBaseDados = class(TfrmBase)
    dtsDados: TDataSource;
    MainMenu: TMainMenu;
    ActionList: TActionList;
    DatasetFirst1: TDataSetFirst;
    DatasetPrior1: TDataSetPrior;
    DatasetNext1: TDataSetNext;
    DatasetLast1: TDataSetLast;
    DatasetInsert1: TDataSetInsert;
    DatasetDelete1: TDataSetDelete;
    DatasetEdit1: TDataSetEdit;
    DatasetPost1: TDataSetPost;
    DatasetCancel1: TDataSetCancel;
    DatasetRefresh1: TDataSetRefresh;
  private
    FDmdCadastro: TdmdBaseCadastro;
    procedure SetDataSets;
    function GetDmdCadastro: TdmdBaseCadastro;
    procedure SetDmdCadastro(const Value: TdmdBaseCadastro);
  protected
    class function GetClasseDmdBaseCadastro: TdmdBaseCadastroClass; virtual; abstract;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; ADmdCadastro: TdmdBaseCadastro); reintroduce; overload;
    property DmdCadastro: TdmdBaseCadastro read GetDmdCadastro write SetDmdCadastro;
  end;

var
  frmBaseDados: TfrmBaseDados;

implementation

{$R *.dfm}

{ TfrmBaseDados }

constructor TfrmBaseDados.Create(AOwner: TComponent);
begin
  inherited;
  SetDmdCadastro(GetClasseDmdBaseCadastro.Create(Self));
end;

constructor TfrmBaseDados.Create(AOwner: TComponent;
  ADmdCadastro: TdmdBaseCadastro);
begin
  inherited Create(AOwner);
  SetDmdCadastro(ADmdCadastro);
end;

function TfrmBaseDados.GetDmdCadastro: TdmdBaseCadastro;
begin
  Result := FDmdCadastro;
  if not Assigned(Result) then
  begin
    raise Exception.Create('Data module base n�o criado.');
  end;
end;

procedure TfrmBaseDados.SetDataSets;
begin
  dtsDados.DataSet := FDmdCadastro.cdsCadastro;
end;

procedure TfrmBaseDados.SetDmdCadastro(const Value: TdmdBaseCadastro);
begin
  if FDmdCadastro <> Value then
  begin
    FDmdCadastro := Value;
    if Assigned(FDmdCadastro) then
    begin
      SetDataSets;
    end;
  end;
end;

end.
