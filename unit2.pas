unit Unit2;

{$mode objfpc}{$H+}

interface

uses
 Classes, SysUtils, FileUtil, TAGraph, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLType, ExtCtrls, ColorBox, ComCtrls, Grids, Spin,
  TASeries, TATypes, TAFuncSeries, TARadialSeries, TATools, TAChartUtils, Types;

type

  { TFrame1 }

  TFrame1 = class(TFrame)
    Chart1: TChart;
    ChartToolset1: TChartToolset;
    ChartToolset1PanMouseWheelTool1: TPanMouseWheelTool;
    procedure Graphic2D;
    procedure Points2D;
    procedure clearGraphics;
  private
    { private declarations }
  public
    { public declarations }
  end;

implementation

uses
  Unit1, Unit4;

{$R *.lfm}

{
plotfunc('x','x',0,10)
plotfunc('5','x',0,10)
plotinter('5','x',0,10)
clearplots
}

procedure TFrame1.clearGraphics;
begin
  Form1.ActiveFunction:=-1;
  Form1.FunctionList.Clear;
  Chart1.ClearSeries;
  Form1.InterSeries:=TLineSeries.Create(Chart1);
  Chart1.AddSeries(Form1.InterSeries);
  Form1.minimizeChart();
end;

procedure TFrame1.Points2D;
var x, h: Real;
   i: integer;
begin

  with ( Form1.InterSeries ) do begin
       //LinePen.Color:= colorbtnFunction.ButtonColor;
       //LinePen.Width:= TrackBar1.Position;
    Clear;
    ShowPoints:=true;
    LineType:=ltNone;
    Pointer.Brush.Color:=clRed;
    Pointer.Style:=psCircle ;
    i:= 0;
    repeat
      AddXY( TFrame3(Form1.CmdFrame).pointsToPlot.get_element(i,0), TFrame3(Form1.CmdFrame).pointsToPlot.get_element(i,1) );
      i:=i+1;
    until ( i=TFrame3(Form1.CmdFrame).pointsToPlot.cfil)
  end;
end;

procedure TFrame1.Graphic2D;
var x, h: Real;
   i: integer;
begin
  Form1.ActiveFunction:=Form1.ActiveFunction+1;
  Form1.FunctionList.Add( TLineSeries.Create(TFrame1(Form1.CharFrame).Chart1 ) );
  with TLineSeries( Form1.FunctionList[ Form1.ActiveFunction ] ) do begin
    Clear;
    ShowPoints:=false;
    LineType:=ltFromPrevious;
    i:= 0;
    repeat
      AddXY( TFrame3(Form1.CmdFrame).pointsToPlot.get_element(i,0), TFrame3(Form1.CmdFrame).pointsToPlot.get_element(i,1) );
      i:=i+1;
    until ( i=TFrame3(Form1.CmdFrame).pointsToPlot.cfil)
  end;
  TFrame1(Form1.CharFrame).Chart1.AddSeries( TLineSeries( Form1.FunctionList[ Form1.FunctionList.Count - 1 ] ) );
end;

end.

