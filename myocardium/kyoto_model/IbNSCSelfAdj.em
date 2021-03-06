@{'''
Author Maria Takeuchi
Author Yasuhiro Naito

Version 0.2 2008-11-30 01:54:55 +0900

	<backGroundCurrent name="IbNSC" initial_value="-57.13324953461715"
		className="org.simBio.bio.terashima_et_al_2006.current.cf.CfChannel">
		<parameter name="permeabilityNa" initial_value="5.69E-4" units="pA/mM" />
		<parameter name="permeabilityK" initial_value="2.276E-4" units="pA/mM" />
		<link name="Cm" initial_value="../membrane capacitance" />
		<link name="constantFieldNa" initial_value="../constantFieldNa" units="mM" />
		<link name="constantFieldK" initial_value="../constantFieldK" units="mM" />
		<link name="constantFieldCa" initial_value="../constantFieldCa" units="mM" />
		<link name="constantFieldCl" initial_value="../constantFieldCl" units="mM" />
		<link name="current" initial_value="../current" />
		<link name="currentNa" initial_value="../currentNa" />
		<link name="currentK" initial_value="../currentK" />
		<link name="currentCa" initial_value="../currentCa" />
		<link name="currentCl" initial_value="../currentCl" />
	</backGroundCurrent>
'''}

System System(/CELL/MEMBRANE/IbNSC)
{
	StepperID	ODE;

	Variable Variable( I )
	{
		Value @IbNSC_I;
	}

	Variable Variable( i )
	{
		Value 211.2;
	}

	Variable Variable( cNa )
	{
		Value -57.1399019601;
	}

	Variable Variable( cK )
	{
		Value 0.00665242529949;
	}

	Process IbNSCAssignmentProcess( I ) 
	{
		StepperID	PSV;
		Priority	20;

		VariableReferenceList
			[ i    :.:i                        1 ]
			[ GX   :../../CYTOPLASM:bNSC_gene  0 ]
			[ Cm   :..:Cm                      0 ]
			[ cNa  :.:cNa                      1 ]
			[ CFNa :..:CFNa                    0 ]
			[ cK   :.:cK                       1 ]
			[ CFK  :..:CFK                     0 ]
			[ I    :.:I                        1 ];

		permeabilityNa  5.69E-4;
		permeabilityK   @( 5.69E-4 * 0.4 );	# 2.276E-4
		pOpen           1.0;
	}

	Variable Variable( state )
	{
		Value -1.0;
	}

	Variable Variable( t_prev )
	{
		Value 0.0;
	}

	Variable Variable( Na_prev )
	{
		Value 0.0;
	}

	Process PythonProcess( AdjustGX ) 
	{
		StepperID	PSV;
		Priority	20;

		VariableReferenceList
			[ state   :.:state                 1 ]
			[ Na_prev :.:Na_prev               1 ]
			[ I    :.:I                        0 ]
			[ Na   :../../CYTOPLASM:Na         0 ]
			[ GX   :../../CYTOPLASM:bNSC_gene  1 ];

		k             1000.0;

		@# 総電流が正から負に転じた時点の[Na]iの前回との差に応じて調節する。[Na]i↑なら、GX↓
		InitializeMethod '''
Na_prev.Value = Na.MolarConc
Na0 = Na.MolarConc
#print( "initialized" )
''';

		FireMethod '''
if ( I.Value <= 0.0 ) and ( state.Value > 0.0 ):
	#GX_new = GX.Value - ( Na.MolarConc - Na_prev.Value ) * k
	GX_new = GX.Value - ( Na.MolarConc - Na0 ) * k

	if GX_new >= 0.1: GX.Value = GX_new
	else:             GX.Value = 0.1

	state.Value = -1.0
	Na_prev.Value = Na.MolarConc

elif ( I.Value > 0.0 ) and ( state.Value < 0.0 ):
	state.Value = 1.0
''';

	}

	@setCurrents( [ 'I' ], [ 'Na', 'cNa' ], [ 'K', 'cK' ] )

}


