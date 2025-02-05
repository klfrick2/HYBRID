within NHES.Systems.PrimaryHeatSystem.HTGR.Data;
model Data_CS

  extends BaseClasses.Record_Data;
  parameter Modelica.Units.SI.Temperature T_Rx_Exit_Ref = 850;
  parameter Modelica.Units.SI.MassFlowRate m_flow_nom = 600;
  annotation (
    defaultComponentName="data",
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={Text(
          lineColor={0,0,0},
          extent={{-100,-90},{100,-70}},
          textString="changeMe")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
</html>"));
end Data_CS;
