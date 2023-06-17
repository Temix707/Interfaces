# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BIT_D" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_REG" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADR { PARAM_VALUE.ADR } {
	# Procedure called to update ADR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADR { PARAM_VALUE.ADR } {
	# Procedure called to validate ADR
	return true
}

proc update_PARAM_VALUE.BIT_D { PARAM_VALUE.BIT_D } {
	# Procedure called to update BIT_D when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BIT_D { PARAM_VALUE.BIT_D } {
	# Procedure called to validate BIT_D
	return true
}

proc update_PARAM_VALUE.NUM_REG { PARAM_VALUE.NUM_REG } {
	# Procedure called to update NUM_REG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_REG { PARAM_VALUE.NUM_REG } {
	# Procedure called to validate NUM_REG
	return true
}


proc update_MODELPARAM_VALUE.ADR { MODELPARAM_VALUE.ADR PARAM_VALUE.ADR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADR}] ${MODELPARAM_VALUE.ADR}
}

proc update_MODELPARAM_VALUE.BIT_D { MODELPARAM_VALUE.BIT_D PARAM_VALUE.BIT_D } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BIT_D}] ${MODELPARAM_VALUE.BIT_D}
}

proc update_MODELPARAM_VALUE.NUM_REG { MODELPARAM_VALUE.NUM_REG PARAM_VALUE.NUM_REG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_REG}] ${MODELPARAM_VALUE.NUM_REG}
}

