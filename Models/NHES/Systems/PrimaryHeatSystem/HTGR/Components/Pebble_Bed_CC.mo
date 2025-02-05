within NHES.Systems.PrimaryHeatSystem.HTGR.Components;
model Pebble_Bed_CC
    extends BaseClasses.Partial_SubSystem_A(redeclare replaceable CS_Dummy CS,
    redeclare replaceable ED_Dummy ED,
    redeclare Data.Data_HTGR_Pebble data(
    Q_total=600000000,
    Q_total_el=300000000,
    K_P_Release=10000,
    m_flow=637.1,
      length_core=10,
    r_outer_fuelRod=0.03,
    th_clad_fuelRod=0.025,
    th_gap_fuelRod=0.02,
    r_pellet_fuelRod=0.01,
    pitch_fuelRod=0.06,
      sizeAssembly=17,
      nRodFuel_assembly=264,
      nAssembly=12,
    HX_Reheat_Tube_Vol=0.1,
    HX_Reheat_Shell_Vol=0.1,
    HX_Reheat_Buffer_Vol=0.1));

  replaceable package Coolant_Medium =
      NHES.Systems.PrimaryHeatSystem.HTGR.BaseClasses.He_HighT                                  annotation(choicesAllMatching = true,dialog(group="Media"));
  replaceable package Fuel_Medium =  TRANSFORM.Media.Solids.UO2                                   annotation(choicesAllMatching = true,dialog(group = "Media"));
  replaceable package Pebble_Medium =
      Media.Solids.Graphite_5                                                                                   annotation(dialog(group = "Media"),choicesAllMatching=true);
      replaceable package Aux_Heat_App_Medium =
      Modelica.Media.Water.StandardWater                                           annotation(choicesAllMatching = true, dialog(group = "Media"));
      replaceable package Waste_Heat_App_Medium =
      Modelica.Media.Water.StandardWater                                            annotation(choicesAllMatching = true, dialog(group = "Media"));

  //Modelica.Units.SI.Power Q_Recup;

    Modelica.Units.SI.Power Q_gen;
    Real cycle_eff;

    Modelica.Units.SI.Power Q_Trans;
    parameter Real eff = 0.9;
  TRANSFORM.Fluid.Volumes.SimpleVolume Core_Outlet(
    redeclare package Medium =
        Coolant_Medium,
    p_start=dataInitial.P_Core_Outlet,
    T_start=dataInitial.T_Core_Outlet,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.LumpedVolume.GenericVolume
        (V=0)) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-68,-20})));
  GasTurbine.Turbine.Turbine      turbine(
    redeclare package Medium =
       Coolant_Medium,
    pstart_out=dataInitial.P_Turbine_Ref,
    Tstart_in=dataInitial.TStart_In_Turbine,
    Tstart_out=dataInitial.TStart_Out_Turbine,
    eta0=data.Turbine_Efficiency,
    PR0=data.Turbine_Pressure_Ratio,
    w0=data.Turbine_Nominal_MassFlowRate)
            annotation (Placement(transformation(extent={{-72,-16},{-20,22}})));
  Fluid.HeatExchangers.Generic_HXs.NTU_HX_SinglePhase Reheater(
    NTU=data.HX_Reheat_NTU,
    K_tube=data.HX_Reheat_K_tube,
    K_shell=data.HX_Reheat_K_shell,
    redeclare package Tube_medium =
        Coolant_Medium,
    redeclare package Shell_medium =
        Coolant_Medium,
    V_Tube=data.HX_Reheat_Tube_Vol,
    V_Shell=data.HX_Reheat_Shell_Vol,
    V_buffers=data.HX_Reheat_Buffer_Vol,
    p_start_tube=dataInitial.Recuperator_P_Tube,
    h_start_tube_inlet=dataInitial.Recuperator_h_Tube_Inlet,
    h_start_tube_outlet=dataInitial.Recuperator_h_Tube_Outlet,
    p_start_shell=dataInitial.Recuperator_P_Tube,
    h_start_shell_inlet=dataInitial.Recuperator_h_Shell_Inlet,
    h_start_shell_outlet=dataInitial.HX_Aux_h_tube_out,
    dp_init_tube=dataInitial.Recuperator_dp_Tube,
    dp_init_shell=dataInitial.Recuperator_dp_Shell,
    Q_init=-100000000,
    Cr_init=0.8,
    m_start_tube=dataInitial.Recuperator_m_Tube,
    m_start_shell=dataInitial.Recuperator_m_Shell)
    annotation (Placement(transformation(extent={{10,-36},{-10,-16}})));

  TRANSFORM.Fluid.Sensors.TemperatureTwoPort sensor_T(redeclare package Medium =
        Coolant_Medium)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={12,-6})));
  TRANSFORM.Fluid.Volumes.SimpleVolume Precooler(
    redeclare package Medium =
        Coolant_Medium,
    p_start=dataInitial.P_HP_Comp_Ref,
    T_start=data.T_Precooler,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.LumpedVolume.GenericVolume
        (V=0),
    use_HeatPort=true) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={26,34})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature    boundary3(use_port=
        false, T=data.T_Precooler)
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-2,34})));
  GasTurbine.Compressor.Compressor      compressor(
    redeclare package Medium =
        Coolant_Medium,
    pstart_in=dataInitial.P_LP_Comp_Ref,
    Tstart_in=dataInitial.TStart_LP_Comp_In,
    Tstart_out=dataInitial.TStart_LP_Comp_Out,
    eta0=data.LP_Comp_Efficiency,
    PR0=data.LP_Comp_P_Ratio,
    w0=data.LP_Comp_MassFlowRate)
            annotation (Placement(transformation(extent={{40,28},{84,60}})));
  TRANSFORM.Fluid.Pipes.TransportDelayPipe
                                       transportDelayPipe(
    redeclare package Medium =
        Coolant_Medium,
    crossArea=data.A_HPDelay,
    length=data.L_HPDelay)
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={84,20})));
  TRANSFORM.Fluid.Volumes.SimpleVolume Intercooler(
    redeclare package Medium =
        Coolant_Medium,
    p_start=dataInitial.P_LP_Comp_Ref,
    T_start=data.T_Intercooler,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.LumpedVolume.GenericVolume
        (V=0.0),
    use_HeatPort=true,
    Q_gen=-Q_Trans)    annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={86,-62})));
  TRANSFORM.HeatAndMassTransfer.BoundaryConditions.Heat.Temperature    boundary4(use_port=
        false, T=data.T_Intercooler)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=180,
        origin={114,-62})));
  GasTurbine.Compressor.Compressor      compressor1(
    redeclare package Medium =
        Coolant_Medium,
    allowFlowReversal=false,
    pstart_in=dataInitial.P_HP_Comp_Ref,
    Tstart_in=dataInitial.TStart_HP_Comp_In,
    Tstart_out=dataInitial.TStart_HP_Comp_Out,
    eta0=data.HP_Comp_Efficiency,
    PR0=data.HP_Comp_P_Ratio,
    w0=data.HP_Comp_MassFlowRate)
            annotation (Placement(transformation(extent={{25,-18},{-25,18}},
        rotation=0,
        origin={-1,-122})));
  TRANSFORM.Fluid.Pipes.TransportDelayPipe
                                       transportDelayPipe1(
    redeclare package Medium =
        Coolant_Medium,
    crossArea=data.A_HPDelay,
    length=data.L_HPDelay)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={20,-52})));
  BalanceOfPlant.StagebyStageTurbineSecondary.Control_and_Distribution.SpringBallValve
    springBallValve(
    redeclare package Medium = Coolant_Medium,
    p_spring=data.P_Release,
    K=data.K_P_Release,
    opening_init=0.)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=90,
        origin={4,58})));
  TRANSFORM.Fluid.BoundaryConditions.Boundary_ph boundary5(
    redeclare package Medium = Coolant_Medium,
    p=data.P_Release,
    nPorts=1)
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=90,
        origin={4,86})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort Core_Inlet_T(redeclare package
      Medium = Coolant_Medium) annotation (Placement(transformation(
        extent={{-6,8},{6,-8}},
        rotation=180,
        origin={-16,-46})));

 /*             Data.Data_HTGR_Pebble
                          data(
    redeclare package Coolant_Medium =
        NHES.Systems.PrimaryHeatSystem.HTGR.BaseClasses.He_HighT,
    redeclare package Fuel_Medium = TRANSFORM.Media.Solids.UO2,
    redeclare package Pebble_Medium =
        TRANSFORM.Media.Solids.Graphite.Graphite_5,
    redeclare package Aux_Heat_App_Medium = Modelica.Media.Water.StandardWater,
    redeclare package Waste_Heat_App_Medium =
        Modelica.Media.Water.StandardWater,
    Q_total=600000000,
    Q_total_el=300000000,
    K_P_Release=10000,
    m_flow=637.1,
    r_outer_fuelRod=0.03,
    th_clad_fuelRod=0.025,
    th_gap_fuelRod=0.02,
    r_pellet_fuelRod=0.01,
    pitch_fuelRod=0.06,
    nAssembly=37,
    HX_Reheat_Tube_Vol=0.1,
    HX_Reheat_Shell_Vol=0.1,
    HX_Reheat_Buffer_Vol=0.1)
    annotation (Placement(transformation(extent={{-100,50},{-80,70}})));*/

  Data.DataInitial_HTGR_Pebble
                      dataInitial
    annotation (Placement(transformation(extent={{80,124},{100,144}})));

  Fluid.HeatExchangers.Generic_HXs.NTU_HX_SinglePhase Steam_Offtake(
    NTU=1.6,
    K_tube=1,
    K_shell=1,
    redeclare package Tube_medium =
        Coolant_Medium,
    redeclare package Shell_medium = Aux_Heat_App_Medium,
    V_Tube=3,
    V_Shell=3,
    V_buffers=1,
    p_start_tube=5920000,
    h_start_tube_inlet=3600e3,
    h_start_tube_outlet=2900e3,
    p_start_shell=1000000,
    h_start_shell_inlet=600e3,
    h_start_shell_outlet=1000e3,
    dp_init_tube=30000,
    dp_init_shell=40000,
    Q_init=-100000000,
    Cr_init=0.8,
    m_start_tube=296.1,
    m_start_shell=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-90,20})));
  Fluid.HeatExchangers.Generic_HXs.NTU_HX_SinglePhase Steam_Reheat_Waste(
    NTU=10,
    K_tube=1,
    K_shell=1,
    redeclare package Tube_medium =
        Coolant_Medium,
    redeclare package Shell_medium = Waste_Heat_App_Medium,
    V_Tube=0.1,
    V_Shell=0.1,
    V_buffers=0.1,
    p_start_tube=1990000,
    h_start_tube_inlet=2307e3,
    h_start_tube_outlet=3600e3,
    p_start_shell=400000,
    h_start_shell_inlet=600e3,
    h_start_shell_outlet=700e3,
    dp_init_tube=30000,
    dp_init_shell=40000,
    Q_init=-1e7,
    Cr_init=0.8,
    m_start_tube=296.1,
    m_start_shell=296.1) annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={46,-12})));
  TRANSFORM.Fluid.Volumes.SimpleVolume Waste_Heat_Vol(
    redeclare package Medium = Waste_Heat_App_Medium,
    p_start=450000,
    T_start=353.15,
    redeclare model Geometry =
        TRANSFORM.Fluid.ClosureRelations.Geometry.Models.LumpedVolume.GenericVolume
        (V=0),
    Q_gen=Q_Trans) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={66,-58})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort Intercooler_Pre_Temp(redeclare
      package Medium = Coolant_Medium) annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=90,
        origin={86,-32})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort CC_Mid_Temp(redeclare package
      Medium = Waste_Heat_App_Medium) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={66,4})));
  TRANSFORM.Fluid.Sensors.Temperature Core_Outlet_T(redeclare package Medium =
        Coolant_Medium) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-68,-58})));
  Modelica.Fluid.Interfaces.FluidPort_a combined_cycle_port_a(redeclare package
      Medium = Waste_Heat_App_Medium)                         annotation (
      Placement(transformation(extent={{22,-110},{42,-90}}),
                                                           iconTransformation(
          extent={{22,-110},{42,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_b combined_cycle_port_b(redeclare package
      Medium = Waste_Heat_App_Medium)                         annotation (
      Placement(transformation(extent={{-66,-110},{-46,-90}}),
                                                             iconTransformation(
          extent={{-66,-110},{-46,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_a auxiliary_heating_port_a(redeclare
      package Medium =
               Aux_Heat_App_Medium)  annotation (
      Placement(transformation(extent={{-110,50},{-90,70}}),
        iconTransformation(extent={{-110,50},{-90,70}})));
  Modelica.Fluid.Interfaces.FluidPort_b auxiliary_heating_port_b(redeclare
      package Medium =
               Aux_Heat_App_Medium)  annotation (
      Placement(transformation(extent={{-110,-56},{-90,-36}}),
                                                             iconTransformation(
          extent={{-110,-56},{-90,-36}})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort CC_Inlet_Temp(redeclare package
      Medium = Waste_Heat_App_Medium) annotation (Placement(
        transformation(
        extent={{8,7},{-8,-7}},
        rotation=270,
        origin={66,-85})));
  TRANSFORM.Fluid.Sensors.TemperatureTwoPort CC_Outlet_Temp(redeclare package
      Medium = Waste_Heat_App_Medium) annotation (Placement(
        transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={44,-74})));
  Nuclear.CoreSubchannels.Pebble_Bed_2 core(
    redeclare package Fuel_Kernel_Material = TRANSFORM.Media.Solids.UO2,
    redeclare package Pebble_Material = NHES.Media.Solids.Graphite_5,
    redeclare model HeatTransfer =
        TRANSFORM.Fluid.ClosureRelations.HeatTransfer.Models.DistributedPipe_1D_MultiTransferSurface.Nus_DittusBoelter_Simple,

    Q_fission_input=600000000,
    alpha_fuel=-5e-5,
    alpha_coolant=0.0,
    p_b_start(displayUnit="bar") = dataInitial.P_Core_Outlet,
    Q_nominal=600000000,
    SigmaF_start=26,
    p_a_start(displayUnit="bar") = dataInitial.P_Core_Inlet,
    T_a_start(displayUnit="K") = dataInitial.T_Core_Inlet,
    T_b_start(displayUnit="K") = dataInitial.T_Core_Outlet,
    m_flow_a_start=data.m_flow,
    exposeState_a=false,
    exposeState_b=false,
    Ts_start(displayUnit="degC"),
    fissionProductDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    redeclare record Data_DH =
        TRANSFORM.Nuclear.ReactorKinetics.Data.DecayHeat.decayHeat_11_TRACEdefault,

    redeclare record Data_FP =
        TRANSFORM.Nuclear.ReactorKinetics.Data.FissionProducts.fissionProducts_H3TeIXe_U235,

    rho_input=CR_reactivity.y,
    redeclare package Medium = BaseClasses.He_HighT,
    SF_start_power={0.2,0.3,0.3,0.2},
    nParallel=data.nAssembly,
    redeclare model Geometry =
        TRANSFORM.Nuclear.ClosureRelations.Geometry.Models.CoreSubchannels.Assembly
        (
        width_FtoF_inner=data.sizeAssembly*data.pitch_fuelRod,
        rs_outer={data.r_pellet_fuelRod,data.r_pellet_fuelRod + data.th_gap_fuelRod,
            data.r_outer_fuelRod},
        length=data.length_core,
        nPins=data.nRodFuel_assembly,
        nPins_nonFuel=data.nRodNonFuel_assembly,
        angle=1.5707963267949),
    toggle_ReactivityFP=false,
    Q_shape={0.00921016,0.022452442,0.029926363,0.035801439,0.040191759,
        0.04361119,0.045088573,0.046395024,0.049471251,0.050548587,0.05122695,
        0.051676198,0.051725935,0.048691804,0.051083234,0.050675546,0.049468838,
        0.047862888,0.045913065,0.041222844,0.038816801,0.035268536,0.029550046,
        0.022746578,0.011373949},
    Fh=1.4,
    n_hot=25,
    Teffref_fuel=1273.15,
    Teffref_coolant=923.15,
    T_inlet=723.15,
    T_outlet=1123.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-40,-46})));

  TRANSFORM.Electrical.Interfaces.ElectricalPowerPort_Flow port_a annotation (
      Placement(transformation(extent={{90,10},{110,30}}),
        iconTransformation(extent={{90,10},{110,30}})));
  TRANSFORM.Blocks.RealExpression CR_reactivity
    annotation (Placement(transformation(extent={{104,84},{116,98}})));
  TRANSFORM.Blocks.RealExpression PR_Compressor
    annotation (Placement(transformation(extent={{106,64},{118,78}})));
  Modelica.Blocks.Sources.RealExpression Core_M_flow(y=core.port_a.m_flow)
    annotation (Placement(transformation(extent={{-88,92},{-76,106}})));
initial equation
  Q_Trans = 1e7;
equation
 // Q_Recup =nTU_HX_SinglePhase.geometry.nTubes*abs(sum(nTU_HX_SinglePhase.tube.heatTransfer.Q_flows));
 Q_gen = turbine.Wt - compressor.Wc - compressor1.Wc;
 cycle_eff = Q_gen / core.Q_total.y;

 der(Q_Trans) =eff*min(abs(Intercooler_Pre_Temp.port_a.m_flow*
    Coolant_Medium.specificHeatCapacityCp(Coolant_Medium.setState_pT(
    Intercooler_Pre_Temp.port_a.p, Intercooler_Pre_Temp.T))*(
    Intercooler_Pre_Temp.T - CC_Inlet_Temp.T)), abs(CC_Inlet_Temp.port_a.m_flow*
    (CC_Inlet_Temp.Medium.specificEnthalpy_pT(CC_Inlet_Temp.port_a.p,
    Intercooler_Pre_Temp.T) - CC_Inlet_Temp.Medium.specificEnthalpy_pT(CC_Inlet_Temp.port_a.p,
    CC_Inlet_Temp.T)))) - Q_Trans;
    port_a.W = Q_gen;
  connect(Precooler.heatPort, boundary3.port)
    annotation (Line(points={{20,34},{8,34}}, color={191,0,0}));
  connect(Precooler.port_b, compressor.inlet) annotation (Line(points={{26,40},{
          26,56},{48,56},{48,56.8},{48.8,56.8}},
                                        color={0,127,255}));
  connect(Intercooler.heatPort, boundary4.port)
    annotation (Line(points={{92,-62},{104,-62}},      color={191,0,0}));
  connect(compressor1.outlet, transportDelayPipe1.port_a) annotation (Line(
        points={{-16,-107.6},{-16,-108},{-72,-108},{-72,-70},{20,-70},{20,-62}},
                                                                     color={0,
          127,255}));
  connect(Intercooler.port_b, compressor1.inlet) annotation (Line(points={{86,-68},
          {86,-108},{14,-108},{14,-107.6}},
                                        color={0,127,255}));
  connect(springBallValve.port_b,boundary5. ports[1])
    annotation (Line(points={{4,68},{4,76}},              color={0,127,255}));
  connect(springBallValve.port_a, Precooler.port_b) annotation (Line(points={{4,48},{
          4,44},{26,44},{26,40}},                 color={0,127,255}));
  connect(Reheater.Shell_in, transportDelayPipe1.port_b)
    annotation (Line(points={{10,-28},{20,-28},{20,-42}},
                                                      color={0,127,255}));
  connect(Reheater.Shell_out, Core_Inlet_T.port_a) annotation (Line(points={{-10,-28},
          {-10,-46}},                                color={0,127,255}));
  connect(turbine.outlet, Reheater.Tube_in) annotation (Line(points={{-30.4,18.2},
          {-30.4,18},{-12,18},{-12,-22},{-10,-22}},
                                              color={0,127,255}));
  connect(Reheater.Tube_out, sensor_T.port_a)
    annotation (Line(points={{10,-22},{26,-22},{26,-16},{12,-16}},
                                                       color={0,127,255}));
  connect(Core_Outlet.port_b, Steam_Offtake.Tube_in) annotation (Line(points={{-68,-14},
          {-86,-14},{-86,10}},                        color={0,127,255}));
  connect(Steam_Offtake.Tube_out, turbine.inlet) annotation (Line(points={{-86,30},
          {-86,34},{-60,34},{-60,20},{-61.6,20},{-61.6,18.2}},
                                    color={0,127,255}));
  connect(Steam_Reheat_Waste.Tube_in, sensor_T.port_b)
    annotation (Line(points={{42,-22},{42,-26},{28,-26},{28,8},{12,8},{12,4}},
                                               color={0,127,255}));
  connect(Steam_Reheat_Waste.Tube_out, Precooler.port_a) annotation (Line(
        points={{42,-2},{42,20},{26,20},{26,28}}, color={0,127,255}));
  connect(compressor.outlet, transportDelayPipe.port_a) annotation (Line(points={{75.2,
          56.8},{74,56.8},{74,58},{84,58},{84,30}},
                                            color={0,127,255}));
  connect(transportDelayPipe.port_b, Intercooler_Pre_Temp.port_b) annotation (
      Line(points={{84,10},{84,-16},{86,-16},{86,-22}},  color={0,127,255}));
  connect(Intercooler.port_a, Intercooler_Pre_Temp.port_a)
    annotation (Line(points={{86,-56},{86,-42}}, color={0,127,255}));
  connect(Waste_Heat_Vol.port_b, CC_Mid_Temp.port_a) annotation (Line(points={{66,-52},
          {66,-8},{80,-8},{80,4},{76,4}},
                                      color={0,0,0}));
  connect(CC_Mid_Temp.port_b, Steam_Reheat_Waste.Shell_in) annotation (Line(
        points={{56,4},{48,4},{48,-2}},                color={0,0,0}));
  connect(Core_Outlet_T.port, Core_Outlet.port_a) annotation (Line(points={{-68,-48},
          {-82,-48},{-82,-26},{-68,-26}},      color={0,127,255}));
  connect(auxiliary_heating_port_a, Steam_Offtake.Shell_in) annotation (Line(
        points={{-100,60},{-86,60},{-86,36},{-92,36},{-92,30}},
        color={0,0,0}));
  connect(Steam_Offtake.Shell_out, auxiliary_heating_port_b) annotation (Line(
        points={{-92,10},{-92,-32},{-84,-32},{-84,-46},{-100,-46}},
        color={0,0,0}));
  connect(combined_cycle_port_a, CC_Inlet_Temp.port_a) annotation (Line(points={{32,-100},
          {32,-86},{54,-86},{54,-96},{66,-96},{66,-93}}, color={0,0,0}));
  connect(CC_Inlet_Temp.port_b, Waste_Heat_Vol.port_a)
    annotation (Line(points={{66,-77},{66,-64}},color={0,0,0}));
  connect(Steam_Reheat_Waste.Shell_out, CC_Outlet_Temp.port_a)
    annotation (Line(points={{48,-22},{48,-26},{54,-26},{54,-74}},
                                                          color={0,0,0}));
  connect(CC_Outlet_Temp.port_b, combined_cycle_port_b) annotation (Line(points={{34,-74},
          {-38,-74},{-38,-84},{-56,-84},{-56,-100}},
                                         color={0,0,0}));
  connect(core.port_a, Core_Inlet_T.port_b) annotation (Line(points={{-30,-46},{
          -22,-46}},                      color={0,127,255}));
  connect(core.port_b, Core_Outlet.port_a) annotation (Line(points={{-50,-46},{-68,
          -46},{-68,-26}},
                 color={0,127,255}));
  connect(combined_cycle_port_b, combined_cycle_port_b)
    annotation (Line(points={{-56,-100},{-56,-100}}, color={0,127,255}));
  connect(actuatorBus.CR_Reactivity, CR_reactivity.u) annotation (Line(
      points={{30,100},{66,100},{66,90},{102.8,90},{102.8,91}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5));
  connect(sensorBus.Core_Outlet_T, Core_Outlet_T.T) annotation (Line(
      points={{-30,100},{-30,74},{-114,74},{-114,-60},{-82,-60},{-82,-58},{-74,-58}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5));

  connect(actuatorBus.PR_Compressor, PR_Compressor.u) annotation (Line(
      points={{30,100},{30,74},{104.8,74},{104.8,71}},
      color={111,216,99},
      pattern=LinePattern.Dash,
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(sensorBus.Core_Mass_Flow, Core_M_flow.y) annotation (Line(
      points={{-30,100},{-75.4,99}},
      color={239,82,82},
      pattern=LinePattern.Dash,
      thickness=0.5));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Bitmap(extent={{-80,-92},{78,84}}, fileName=
              "modelica://NHES/Icons/PrimaryHeatSystemPackage/HTGRPB.jpg")}),
                                                                 Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=10000,
      __Dymola_NumberOfIntervals=591,
      __Dymola_Algorithm="Esdirk45a"),
    Documentation(info="<html>
<p>The goal of the HTGR models is to obtain a baseline functioning model that can be used to investigate HTGR applications within IES. That being the motivation, there are likely incorrect time constants throughout the system without relevant comparative data to use. Note also that the current core model structure, while this loop is described as a pebble bed (prismatic is pending), is still using the old nuclear core geometry file. This is due to some odd modeling failures during attempts to change. I will modify this description should I obtain the correct core functioning with a reasonable geometry. Using the old core geometry to obtain the correct flow values (flow area, hydraulic diameters, Reynolds numbers) should provide accurate-enough information. </p>
<p>The Dittus-Boelter simple correlation for single phase heat transfer in turbulent flow is used to calculate the heat transfer between the fuel and the coolant, and maximum fuel temperatures appear to agree with literature (~1200C). </p>
<p>Separate HTGR models will be developed for different uses. The primary differentiator is whether a combined cycle is going to be integrated or not. The combined cycle thoerized to be used here takes advantage of the relatively hot waste heat that is produced by an HTGR to boil water at low pressure and send that to a turbine. </p>
<p>No part of this HTGR model should be considered to be optimized. Additionally, thermal mass of the system needs references and then will need to be adjusted (likely through pipes replacing current zero-volume volume nodes) to more appropriately reflect system time constants. </p>
</html>"));
end Pebble_Bed_CC;
