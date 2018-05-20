unit ParseNumerico;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, math, fpexprpars, Dialogs,  ExtCtrls,LCLType, ucmdbox, StdCtrls,
  matrizX, matrizfloat, sPila, variable, mathnumerico, matrizNumerico,
  class_taylor, class_close, class_open, class_raphson, class_integral, class_edo, class_regresion, class_lag,
  class_interseccion, class_prediccion;

type
  TParseMath = Class

  Private
      FParser: TFPExpressionParser;
      Procedure AddFunctions();

  Public
      exist: boolean;
      ResultParser: TFPExpressionResult;
      variables: array of TVariable;
      Expression: string;
      procedure AddVariable( Variablename: string; Value: TVariable );
      procedure AddVariable( Value: TVariable );
      function Evaluate(): Double;
      function find(kname: string): integer;
      constructor create();
      destructor destroy();
  end;

implementation

constructor TParseMath.create;
begin
   FParser:= TFPExpressionParser.Create( nil );
   FParser.Builtins := [ bcMath ];
   AddFunctions();
end;

destructor TParseMath.destroy;
begin
    FParser.Destroy;
end;

//

function TParseMath.Evaluate(): Double;
begin
   try
     FParser.Expression:= Expression;
     ResultParser:= FParser.Evaluate;
     ResultParser.ResFloat:=ArgToFloat(ResultParser);
     if(isNaN(ResultParser.ResFloat)=false) then
       ActualVariable:=TVariable.create(ResultParser.ResFloat);
     evaluate:= ResultParser.ResFloat ;
     exist:=true;
   except
     evaluate:=NaN;
     exist:=false;
     exit;
   end;
end;

//dormand('x*y','x','y',2,4,4.5)

//raph('{power(x,2)-3;x+y}','{x;y}','{1;1}')

procedure plotfuncx(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  Parse: TParseMath;
  points:TMFloat;
  left, right, ac: real;
begin
  Parse:=TParseMath.create();
  points:=TMFloat.create;
  left:=ArgToFloat(Args[1]);
  right:=ArgToFloat(Args[2]);
  Parse.Expression:=Args[0].ResString;
  Parse.AddVariable('x',TVariable.create(left));
  Parse.Evaluate();
  if(Parse.exist=false) then begin
     Result.ResString:=points.contenido();
     exit;
  end;
  ac:=(right-left)/800;
  while (left<right) do begin
      Parse.AddVariable('x',TVariable.create(left));
        points.push_list('{'+floattostr(left)+';'+floattostr(Parse.Evaluate())+'}',false);
      left:=left+ac;
  end;
  Result.ResString:=points.contenido();
end;

//'2.49458582384087*exp(0.997457834387947*x)-(0)'

procedure plotfunc(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  Parse: TParseMath;
  points:TMFloat;
  left, right, ac: real;
begin
  Parse:=TParseMath.create();
  points:=TMFloat.create;
  left:=ArgToFloat(Args[2]);
  right:=ArgToFloat(Args[3]);
  Parse.Expression:=Args[0].ResString;
  Parse.AddVariable(Args[1].ResString,TVariable.create(left));
  Parse.Evaluate();
  if(Parse.exist=false) then begin
     Result.ResString:=points.contenido();
     exit;
  end;
  ac:=(right-left)/800;
  while (left<right) do begin
      Parse.AddVariable(Args[1].ResString,TVariable.create(left));
        points.push_list('{'+floattostr(left)+';'+floattostr(Parse.Evaluate())+'}',false);
      left:=left+ac;
  end;
  Result.ResString:=points.contenido();
end;

//plotfunc1('1/x','x',-10,10,200)

procedure plotfunc1(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  Parse: TParseMath;
  points:TMFloat;
  left, right, ac: real;
begin
  Parse:=TParseMath.create();
  points:=TMFloat.create;
  left:=ArgToFloat(Args[2]);
  right:=ArgToFloat(Args[3]);
  Parse.Expression:=Args[0].ResString;
  Parse.AddVariable(Args[1].ResString,TVariable.create(0));
  ac:=(right-left)/(ArgToFloat(Args[4]));
  while (left<right) do begin
      Parse.AddVariable(Args[1].ResString,TVariable.create(left));
      points.push_list('{'+floattostr(left)+';'+floattostr(Parse.Evaluate())+'}',false);
      left:=left+ac;
  end;
  Result.ResString:=points.contenido();
  ActualVariable:=Tvariable.create(TMatriz.create(points));
  Result.ResFloat:=NaN;
end;

procedure plotpoints(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  points:TMFloat;
begin
  try
    points:=TMFloat.create(Args[0].ResString);
    Result.ResString:=points.contenido();
  except
    points:=TMFloat.create ;
    Result.ResString:=points.contenido();
  end;
  ActualVariable:=Tvariable.create(TMatriz.create(points));
  Result.ResFloat:=NaN;
end;

procedure getElement(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var mat: TMatriz;
  i,j: integer;
begin
      mat:=TMatriz.create(Args[0].ResString);
      i:=round(ArgToFloat(Args[1]));
      j:=round (ArgToFloat(Args[2]));
      Result.ResFloat:=mat.get_element(i,j);
      ActualVariable:=TVariable.create(result.resfloat);
end;

procedure getArea(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var
  integral: TIntegral;
  expr: string;
begin
  integral:=TIntegral.create();
      expr:=Args[0].ResString+'-('+Args[1].ResString+')';
      integral.cArea:=true;
      integral.Parse.Expression:=expr;
      Integral.n:=10000;
      integral.Parse.AddVariable('x',0);
      Result.ResFloat:=integral.simpson3(ArgToFloat(Args[2]),ArgToFloat(Args[3]));
      ActualVariable:=TVariable.create(result.resfloat);
end;

procedure pointsFile(var Result: TFPExpressionResult; Const Args: TExprParameterArray);
var points:TMFloat;
  dir: string;
  DText: TStringList;
  i: integer;
  line: string;
begin
  Dir:=ExtractFileDir(ParamStr(0))+ '/../../../RNL/' + Args[0].ResString;
  //Dir:=ExtractFileDir(ParamStr(0))+ PathDelim + Args[0].ResString;
   points:=TMFloat.create();
   if FileExists(Dir) then begin
    DText          := TStringList.Create;
    DText.LoadFromFile(Dir);
    for i:=0 to DText.Count-1 do begin
        line:=DText[i];
        points.push_list(line,true);
    end;
    Result.ResString:=points.contenido();
  end else begin
      Result.ResString := 'Path: '''+Dir+''', no existe';//points.contenido();
  end;
  ActualVariable:=Tvariable.create(TMatriz.create(points));
  Result.ResFloat:=NaN;
end;

{***************AREA****************
//inicia x,y,l,r
plotfunc(x,'x',l,r)
plotfunc(y,'x',l,r)
z=inter(x,y,l,r)
//inicia tam
x1=getelement(z,0,0)
x2=getelement(z,tam-1,0)
//inicia
ar=getarea(x,y,x1,x2)
}
{
x='(3*exp(t)*tan(x))/(-(2-exp(t))*power((1/cos(x)),2))'
y=dormand(x,'t','x',0.7,7/4,2)
}

{
 f1=[{6;-1.676}{7;4.599}{7.5;7.035}{8;7.915}{9.5;-0.714}]
 f2=[{6;3.349}{6.5;3.473}{7;3.597}{8;3.847}{9;4.096}{10;4.343}]
}

Procedure TParseMath.AddFunctions();
begin
   with FParser.Identifiers do begin
       {MATH NUMERICO}
       AddFunction('tan', 'F', 'F', @ExprTan);
       AddFunction('sin', 'F', 'F', @ExprSin);
       AddFunction('sen', 'F', 'F', @ExprSin);
       AddFunction('cos', 'F', 'F', @ExprCos);
       AddFunction('ln', 'F', 'F', @ExprLn);
       AddFunction('log', 'F', 'F', @ExprLog);
       AddFunction('sqrt', 'F', 'F', @ExprSQRT);
       AddFunction('power', 'F', 'FF', @ExprPower); //two arguments 'FF'
       //AddFunction('tsen', 'F', 'FF', @ExprTaylorSin);
       //AddFunction('tcos', 'F', 'FF', @ExprTaylorCos);
       //AddFunction('texp', 'F', 'FF', @ExprTaylorExp);

       {TAYLOR}
       AddFunction('tsen', 'F', 'F', @ExprTaylorSinD);
       AddFunction('tcos', 'F', 'F', @ExprTaylorCosD);
       AddFunction('texp', 'F', 'F', @ExprTaylorExpD);

       {MATRIZ NUMERICO}
       AddFunction('sum','S','SS',@sumMatrices);
       AddFunction('res','S', 'SS', @resMatrices);
       AddFunction('mult','S','SS', @multMatrices);
       AddFunction('multReal','S','SF',@multRealMat);
       AddFunction('trans', 'S', 'S', @transMat);
       AddFunction('getElement', 'S', 'SFF', @getElement);
       AddFunction('getRow', 'S', 'SF', @getRow);

       {CLOSE}
       AddFunction('bisec', 'F', 'SSFF', @biseccion);
       AddFunction('fpos', 'F', 'SSFF', @falsaPosicion);

       {OPEN}
       AddFunction('newt', 'F', 'SSSF', @newton);
       AddFunction('secan', 'F', 'SSF', @secante);

       {INTERSECCION}
       AddFunction('inter', 'S', 'SSFF', @intersec);
       AddFunction('interplus', 'S', 'SSFFFF', @intersecplus);

       {RAPHSON}
       AddFunction('raph','S','SSS', @raphson);

       {INTEGRAL}
       AddFunction('pmedio', 'F','SSFF', @puntomedio);
       AddFunction('trap', 'F','SSFF', @trapecio);
       AddFunction('sim1', 'F','SSFF', @simpson1);
       AddFunction('sim3', 'F','SSFF', @simpson3);
       AddFunction('sim1p', 'F','S', @simpson1p);
       AddFunction('getarea','F','SSFF', @getArea);

       {EDO}
       AddFunction('euler', 'F','SSSFFF', @euler);
       AddFunction('heun', 'F','SSSFFF', @heun);
       AddFunction('runge4', 'F','SSSFFF', @runge4);
       AddFunction('dormand', 'F','SSSFFF', @dormand);
       AddFunction('edo', 'F','SFFF', @dormand2);

       {REGRESION}
       AddFunction('lag','S','S', @lagrange);
       AddFunction('rlineal','S','S',@regLineal);
       AddFunction('rexp','S','S',@regNoLinealexp);
       AddFunction('rln','S','S',@regNoLinealln);
       AddFunction('aproxfunc','S','S',@aproxfunc);

       AddFunction('func','S','SFF',@plotfuncX);
       AddFunction('func1','S','SSFF',@plotfunc);
       AddFunction('func2','S','SSFFF',@plotfunc1);
       AddFunction('points', 'S', 'S', @plotpoints);
       AddFunction('pointsfile', 'S', 'S', @pointsfile);
   end
end;

function TParseMath.find(kname: string): integer;
var
i: integer;
begin
  for i:=0 to length(variables)-1 do begin
    if(variables[i].varname=kname) then begin
      result:=i;
      exit;
    end;
  end;
  result:=i;
end;

procedure TParseMath.AddVariable( Variablename: string; Value: TVariable );
var Len,i: Integer;
begin
  Len:= length( variables );
   if(Assigned(FParser.IdentifierByName(Variablename))) then begin
     FParser.IdentifierByName(variablename).FreeInstance;
   end;
   i:= find(variablename);
   if(i=len) then begin
     Len:= len + 1;
     SetLength( variables, Len ) ;
   end;
   variables[ i ]:=Value;
   if(Value.typevalue=0) then begin
     FParser.Identifiers.AddFloatVariable( Variablename, Value.varfloat);
   end else begin
     FParser.Identifiers.AddStringVariable( Variablename, Value.toString());
   end;
end;

procedure TParseMath.AddVariable( Value: TVariable );
var Len,i: Integer;
begin
  Len:= length( variables );
   if(Assigned(FParser.IdentifierByName(value.varname))) then begin
     FParser.IdentifierByName(value.varname).FreeInstance;
   end;
   i:= find(value.varname);
   if(i=len) then begin
     Len:= len + 1;
     SetLength( variables, Len ) ;
   end;
   variables[ i ]:=Value;
   if(Value.typevalue=0) then begin
     FParser.Identifiers.AddFloatVariable( value.varname, Value.varfloat);
   end else begin
     FParser.Identifiers.AddStringVariable( value.varname, Value.toString());
   end;
end;

end.

